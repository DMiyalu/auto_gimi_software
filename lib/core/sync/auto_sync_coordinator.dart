import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/establishment/domain/models/establishment.dart';
import '../../features/establishment/presentation/providers/establishment_providers.dart';
import 'connectivity_service.dart';
import '../../features/establishment/domain/models/establishment_member.dart';
import 'sync_engine.dart';
import 'sync_registry.dart';

final autoSyncCoordinatorProvider = Provider.autoDispose<AutoSyncCoordinator>((
  ref,
) {
  final coordinator = AutoSyncCoordinator(ref);
  ref.onDispose(coordinator.dispose);
  return coordinator;
});

/// Câble les déclencheurs de synchro automatique vers [SyncEngine.runSync] :
/// résolution de l'établissement (login / changement d'appareil), retour de
/// connectivité, retour au premier plan de l'app, minuterie de secours,
/// écritures locales (via [schedulePush], appelé par les contrôleurs), et
/// changements distants détectés en direct (autre appareil du même
/// établissement — plusieurs serveurs en salle, par exemple).
///
/// Vit tant que `AppShellScreen` (routes authentifiées) est monté — un seul
/// cycle de synchro à la fois est garanti par `SyncEngine` lui-même, ce
/// coordinateur se contente de décider *quand* en demander un, avec un
/// backoff exponentiel en cas d'échec (coupure réseau en cours de synchro,
/// erreur serveur…).
class AutoSyncCoordinator {
  AutoSyncCoordinator(this._ref) {
    _establishmentSub = _ref.listen(currentEstablishmentProvider, (
      previous,
      next,
    ) {
      final id = next.valueOrNull?.id;
      if (id != null && id != previous?.valueOrNull?.id) {
        _cancelRealtimeListeners();
        _realtimeEstablishmentId = null;
        _trigger();
      }
    });

    _membershipsSub = _ref.listen(userMembershipsProvider, (previous, next) {
      _trigger();
    });

    _connectivitySub = _ref
        .read(connectivityServiceProvider)
        .watchOnline()
        .listen(_onConnectivityChanged, onError: (_) {});

    _lifecycleListener = AppLifecycleListener(
      onResume: () {
        if (_lastOnline) _trigger();
      },
    );

    _safetyNetTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (_lastOnline) _trigger();
    });

    final initialId = _ref.read(currentEstablishmentProvider).valueOrNull?.id;
    if (initialId != null && _canSync(initialId)) _listenRealtime(initialId);
    _trigger();
  }

  static const _pushDebounce = Duration(milliseconds: 1500);
  static const _connectivityDebounce = Duration(seconds: 2);
  static const _realtimeDebounce = Duration(seconds: 1);
  static const _baseBackoff = Duration(seconds: 5);
  static const _maxBackoff = Duration(minutes: 5);

  final Ref _ref;
  late final ProviderSubscription<AsyncValue<Establishment?>> _establishmentSub;
  late final ProviderSubscription<AsyncValue<List<EstablishmentMember>>>
  _membershipsSub;
  StreamSubscription<bool>? _connectivitySub;
  AppLifecycleListener? _lifecycleListener;
  Timer? _safetyNetTimer;
  Timer? _pushDebounceTimer;
  Timer? _connectivityDebounceTimer;
  Timer? _realtimeDebounceTimer;
  Timer? _backoffTimer;
  Duration _backoff = _baseBackoff;
  bool _lastOnline = false;
  final List<StreamSubscription<QuerySnapshot<Object?>>> _realtimeSubs = [];
  String? _realtimeEstablishmentId;

  /// À appeler par les contrôleurs après une écriture locale réussie :
  /// planifie un cycle de synchro, en regroupant les écritures rapprochées.
  void schedulePush() {
    _pushDebounceTimer?.cancel();
    _pushDebounceTimer = Timer(_pushDebounce, _trigger);
  }

  void _onConnectivityChanged(bool online) {
    _lastOnline = online;
    if (!online) return;
    _connectivityDebounceTimer?.cancel();
    _connectivityDebounceTimer = Timer(_connectivityDebounce, _trigger);
  }

  /// Écoute en direct chaque collection Firestore de l'établissement, pour
  /// détecter en quelques secondes un changement fait par un *autre*
  /// appareil (plusieurs serveurs en salle, chacun avec l'app) — sans
  /// attendre le filet de sécurité (5 min). La requête (`limit(1)` sur le
  /// document le plus récemment modifié) sert uniquement de signal de
  /// réveil : c'est toujours [SyncEngine] qui effectue le pull typé et
  /// incrémental via le curseur `sync_state`.
  void _listenRealtime(String establishmentId) {
    if (_realtimeEstablishmentId == establishmentId) return;
    _cancelRealtimeListeners();
    _realtimeEstablishmentId = establishmentId;

    // Best-effort : appelé synchronement depuis le constructeur (et donc
    // depuis n'importe quel schedulePush() d'un contrôleur métier), ceci ne
    // doit jamais faire échouer l'écriture locale qui l'a déclenché — par
    // exemple si Firebase n'est pas encore initialisé à cet instant précis.
    try {
      final firestore = _ref.read(firestoreProvider);
      if (firestore == null) return;

      final establishmentRef = firestore
          .collection('establishments')
          .doc(establishmentId);

      for (final adapter in defaultSyncAdapters) {
        final sub = establishmentRef
            .collection(adapter.firestoreCollection)
            .orderBy('updatedAt', descending: true)
            .limit(1)
            .snapshots()
            .listen((snapshot) {
              // Un instantané encore local (écriture optimiste de cet
              // appareil, pas confirmée serveur) ne justifie pas de
              // réveiller un cycle : celui déclenché par schedulePush()
              // suffit déjà. On ne réagit qu'aux changements confirmés,
              // potentiellement faits par un autre appareil.
              if (snapshot.metadata.hasPendingWrites) return;
              _scheduleRealtimeTrigger();
            }, onError: (_) {});
        _realtimeSubs.add(sub);
      }
    } catch (error) {
      // Best-effort et récupérable (retenté au prochain trigger réussi) :
      // ne pas remonter via FlutterError.reportError, réservé aux erreurs
      // réellement inattendues.
      debugPrint(
        '[Sync] Écoute temps réel indisponible pour $establishmentId : $error',
      );
    }
  }

  void _scheduleRealtimeTrigger() {
    _realtimeDebounceTimer?.cancel();
    _realtimeDebounceTimer = Timer(_realtimeDebounce, _trigger);
  }

  void _cancelRealtimeListeners() {
    for (final sub in _realtimeSubs) {
      sub.cancel();
    }
    _realtimeSubs.clear();
  }

  void _trigger() {
    final establishmentId = _ref
        .read(currentEstablishmentProvider)
        .valueOrNull
        ?.id;
    if (establishmentId == null) return;
    if (!_canSync(establishmentId)) return;

    _listenRealtime(establishmentId);
    _backoffTimer?.cancel();
    unawaited(_runSync(establishmentId));
  }

  bool _canSync(String establishmentId) {
    final memberships = _ref.read(userMembershipsProvider);
    if (!memberships.hasValue) return false;
    return memberships.valueOrNull?.any(
          (membership) => membership.establishmentId == establishmentId,
        ) ??
        false;
  }

  Future<void> _runSync(String establishmentId) async {
    try {
      await _ref
          .read(syncEngineProvider)
          .runSync(establishmentId: establishmentId);
      _backoff = _baseBackoff;
    } catch (error) {
      // Ne jamais échouer silencieusement : un cycle de synchro cassé (règles
      // Firestore, index manquant, erreur réseau…) doit rester diagnosticable
      // à distance plutôt que de simplement laisser l'app sembler vide. Reste
      // en debugPrint (pas FlutterError.reportError) : récupérable via
      // _scheduleRetry, ce n'est pas une erreur fatale inattendue.
      debugPrint('[Sync] Échec du cycle pour $establishmentId : $error');
      _scheduleRetry();
    }
  }

  void _scheduleRetry() {
    _backoffTimer?.cancel();
    _backoffTimer = Timer(_backoff, _trigger);
    _backoff = Duration(
      milliseconds: (_backoff.inMilliseconds * 2).clamp(
        _baseBackoff.inMilliseconds,
        _maxBackoff.inMilliseconds,
      ),
    );
  }

  void dispose() {
    _establishmentSub.close();
    _membershipsSub.close();
    _connectivitySub?.cancel();
    _lifecycleListener?.dispose();
    _safetyNetTimer?.cancel();
    _pushDebounceTimer?.cancel();
    _connectivityDebounceTimer?.cancel();
    _realtimeDebounceTimer?.cancel();
    _backoffTimer?.cancel();
    _cancelRealtimeListeners();
  }
}
