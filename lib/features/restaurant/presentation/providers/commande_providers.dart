import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/database_provider.dart';
import '../../../../core/sync/auto_sync_coordinator.dart';
import '../../../establishment/presentation/providers/establishment_providers.dart';
import '../../data/repositories/commande_repository_impl.dart';
import '../../domain/entities/commande_entity.dart';
import '../../domain/entities/ligne_commande_entity.dart';
import '../../domain/repositories/commande_repository.dart';

final commandeRepositoryProvider = Provider<CommandeRepository>((ref) {
  return CommandeRepositoryImpl(database: ref.watch(databaseProvider));
});

final commandesProvider = StreamProvider<List<CommandeEntity>>((ref) {
  final establishment = ref.watch(currentEstablishmentProvider).valueOrNull;
  if (establishment == null) return Stream.value(const []);
  return ref
      .watch(commandeRepositoryProvider)
      .watchCommandes(establishmentId: establishment.id);
});

final commandeProvider = StreamProvider.family<CommandeEntity?, String>((
  ref,
  commandeId,
) {
  final establishment = ref.watch(currentEstablishmentProvider).valueOrNull;
  if (establishment == null) return Stream.value(null);
  return ref
      .watch(commandeRepositoryProvider)
      .watchCommande(establishmentId: establishment.id, id: commandeId);
});

final commandeLinesProvider =
    StreamProvider.family<List<LigneCommandeEntity>, String>((ref, commandeId) {
      final establishment = ref.watch(currentEstablishmentProvider).valueOrNull;
      if (establishment == null) return Stream.value(const []);
      return ref
          .watch(commandeRepositoryProvider)
          .watchLignes(
            establishmentId: establishment.id,
            commandeId: commandeId,
          );
    });

final commandeControllerProvider =
    AsyncNotifierProvider<CommandeController, void>(CommandeController.new);

class CommandeController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  String _requireEstablishmentId() {
    final establishment = ref.read(currentEstablishmentProvider).valueOrNull;
    if (establishment == null) {
      throw StateError('Établissement introuvable.');
    }
    return establishment.id;
  }

  void _ensureCanCreateActivities() {
    if (!ref.read(canCreateActivitiesProvider)) {
      throw StateError(
        'Vous n’avez pas le droit de gérer les activités de cet établissement.',
      );
    }
  }

  Future<String> createCommande({String? clientId, String? context}) async {
    final establishmentId = _requireEstablishmentId();
    String? commandeId;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      _ensureCanCreateActivities();
      final commande = await ref
          .read(commandeRepositoryProvider)
          .createCommande(
            establishmentId: establishmentId,
            clientId: clientId,
            context: context,
          );
      commandeId = commande.id;
      ref.read(autoSyncCoordinatorProvider).schedulePush();
    });

    if (state.hasError) throw state.error!;
    return commandeId!;
  }

  Future<void> addProduitLine({
    required String commandeId,
    required String produitId,
    int quantity = 1,
  }) async {
    final establishmentId = _requireEstablishmentId();

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      _ensureCanCreateActivities();
      await ref
          .read(commandeRepositoryProvider)
          .addProduitLine(
            establishmentId: establishmentId,
            commandeId: commandeId,
            produitId: produitId,
            quantity: quantity,
          );
      ref.read(autoSyncCoordinatorProvider).schedulePush();
    });
  }

  Future<void> removeLine({required String lineId}) async {
    final establishmentId = _requireEstablishmentId();

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      _ensureCanCreateActivities();
      await ref
          .read(commandeRepositoryProvider)
          .removeLine(establishmentId: establishmentId, lineId: lineId);
      ref.read(autoSyncCoordinatorProvider).schedulePush();
    });
  }

  Future<void> decrementLine({required String lineId}) async {
    final establishmentId = _requireEstablishmentId();

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      _ensureCanCreateActivities();
      await ref
          .read(commandeRepositoryProvider)
          .decrementLine(establishmentId: establishmentId, lineId: lineId);
      ref.read(autoSyncCoordinatorProvider).schedulePush();
    });
  }

  Future<void> cancelCommande({required String commandeId}) async {
    final establishmentId = _requireEstablishmentId();

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      _ensureCanCreateActivities();
      await ref
          .read(commandeRepositoryProvider)
          .cancelCommande(
            establishmentId: establishmentId,
            commandeId: commandeId,
          );
      ref.read(autoSyncCoordinatorProvider).schedulePush();
    });
  }

  /// Déclenché par l'impression réussie d'une facture : en_cours → à_payer.
  Future<void> markAwaitingPayment({required String commandeId}) async {
    final establishmentId = _requireEstablishmentId();

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      _ensureCanCreateActivities();
      await ref
          .read(commandeRepositoryProvider)
          .markAwaitingPayment(
            establishmentId: establishmentId,
            commandeId: commandeId,
          );
      ref.read(autoSyncCoordinatorProvider).schedulePush();
    });
  }

  /// Déclenché par l'encaissement du paiement : (en_cours ou à_payer) →
  /// clôturée.
  Future<void> registerPayment({
    required String commandeId,
    CommandePaymentMethod paymentMethod = CommandePaymentMethod.cash,
  }) async {
    final establishmentId = _requireEstablishmentId();

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      _ensureCanCreateActivities();
      await ref
          .read(commandeRepositoryProvider)
          .registerPayment(
            establishmentId: establishmentId,
            commandeId: commandeId,
            paymentMethod: paymentMethod,
          );
      ref.read(autoSyncCoordinatorProvider).schedulePush();
    });
  }

  Future<void> attachClient({
    required String commandeId,
    required String clientId,
  }) async {
    final establishmentId = _requireEstablishmentId();

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      _ensureCanCreateActivities();
      await ref
          .read(commandeRepositoryProvider)
          .attachClient(
            establishmentId: establishmentId,
            commandeId: commandeId,
            clientId: clientId,
          );
      ref.read(autoSyncCoordinatorProvider).schedulePush();
    });
  }

  Future<void> detachClient(String commandeId) async {
    final establishmentId = _requireEstablishmentId();

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      _ensureCanCreateActivities();
      await ref
          .read(commandeRepositoryProvider)
          .detachClient(
            establishmentId: establishmentId,
            commandeId: commandeId,
          );
      ref.read(autoSyncCoordinatorProvider).schedulePush();
    });
  }
}
