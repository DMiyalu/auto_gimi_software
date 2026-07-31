import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/establishment/domain/models/establishment.dart';
import '../../features/establishment/presentation/providers/establishment_providers.dart';
import 'connectivity_service.dart';
import 'sync_engine.dart';

final autoSyncCoordinatorProvider =
    Provider.autoDispose<AutoSyncCoordinator>((ref) {
  final coordinator = AutoSyncCoordinator(ref);
  ref.onDispose(coordinator.dispose);
  return coordinator;
});

/// Câble les déclencheurs de synchro automatique vers [SyncEngine.runSync] :
/// résolution de l'établissement (login / changement d'appareil), retour de
/// connectivité, retour au premier plan de l'app, minuterie de secours, et
/// écritures locales (via [schedulePush], appelé par les contrôleurs).
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
        _trigger();
      }
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

    _trigger();
  }

  static const _pushDebounce = Duration(milliseconds: 1500);
  static const _connectivityDebounce = Duration(seconds: 2);
  static const _baseBackoff = Duration(seconds: 5);
  static const _maxBackoff = Duration(minutes: 5);

  final Ref _ref;
  late final ProviderSubscription<AsyncValue<Establishment?>> _establishmentSub;
  StreamSubscription<bool>? _connectivitySub;
  AppLifecycleListener? _lifecycleListener;
  Timer? _safetyNetTimer;
  Timer? _pushDebounceTimer;
  Timer? _connectivityDebounceTimer;
  Timer? _backoffTimer;
  Duration _backoff = _baseBackoff;
  bool _lastOnline = false;

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

  void _trigger() {
    final establishmentId =
        _ref.read(currentEstablishmentProvider).valueOrNull?.id;
    if (establishmentId == null) return;

    _backoffTimer?.cancel();
    unawaited(_runSync(establishmentId));
  }

  Future<void> _runSync(String establishmentId) async {
    try {
      await _ref
          .read(syncEngineProvider)
          .runSync(establishmentId: establishmentId);
      _backoff = _baseBackoff;
    } catch (_) {
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
    _connectivitySub?.cancel();
    _lifecycleListener?.dispose();
    _safetyNetTimer?.cancel();
    _pushDebounceTimer?.cancel();
    _connectivityDebounceTimer?.cancel();
    _backoffTimer?.cancel();
  }
}
