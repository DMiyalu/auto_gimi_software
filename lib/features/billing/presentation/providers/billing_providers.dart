import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/app_currency.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/sync/auto_sync_coordinator.dart';
import '../../../establishment/presentation/providers/establishment_providers.dart';
import '../../data/repositories/billing_repository_impl.dart';
import '../../domain/entities/facture_entity.dart';
import '../../domain/entities/paiement_entity.dart';
import '../../domain/repositories/billing_repository.dart';

final billingRepositoryProvider = Provider<BillingRepository>((ref) {
  return BillingRepositoryImpl(database: ref.watch(databaseProvider));
});

final facturesProvider = StreamProvider<List<FactureEntity>>((ref) {
  final establishment = ref.watch(currentEstablishmentProvider).valueOrNull;
  if (establishment == null) return Stream.value(const []);
  return ref
      .watch(billingRepositoryProvider)
      .watchFactures(establishmentId: establishment.id);
});

final factureForActivityProvider =
    StreamProvider.family<FactureEntity?, BillingActivityRef>((ref, activity) {
      final establishment = ref.watch(currentEstablishmentProvider).valueOrNull;
      if (establishment == null) return Stream.value(null);
      return ref
          .watch(billingRepositoryProvider)
          .watchFactureForActivity(
            establishmentId: establishment.id,
            activityType: activity.type,
            activityId: activity.id,
          );
    });

final paiementsProvider = StreamProvider.family<List<PaiementEntity>, String>((
  ref,
  factureId,
) {
  final establishment = ref.watch(currentEstablishmentProvider).valueOrNull;
  if (establishment == null) return Stream.value(const []);
  return ref
      .watch(billingRepositoryProvider)
      .watchPaiements(establishmentId: establishment.id, factureId: factureId);
});

final billingControllerProvider =
    AsyncNotifierProvider<BillingController, void>(BillingController.new);

class BillingController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  String _requireEstablishmentId() {
    final establishment = ref.read(currentEstablishmentProvider).valueOrNull;
    if (establishment == null) {
      throw StateError('Établissement introuvable.');
    }
    return establishment.id;
  }

  Future<FactureEntity> issueFactureForActivity({
    required BillingActivityType activityType,
    required String activityId,
    required double totalAmount,
    AppCurrency currency = AppCurrency.usd,
  }) async {
    final establishmentId = _requireEstablishmentId();
    FactureEntity? facture;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      facture = await ref
          .read(billingRepositoryProvider)
          .issueFactureForActivity(
            establishmentId: establishmentId,
            activityType: activityType,
            activityId: activityId,
            totalAmount: totalAmount,
            currency: currency,
          );
      ref.read(autoSyncCoordinatorProvider).schedulePush();
    });

    if (state.hasError) throw state.error!;
    return facture!;
  }

  Future<void> recordPayment({
    required String factureId,
    required PaymentMethod method,
    required double amount,
    AppCurrency currency = AppCurrency.usd,
  }) async {
    final establishmentId = _requireEstablishmentId();

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(billingRepositoryProvider)
          .recordPayment(
            establishmentId: establishmentId,
            factureId: factureId,
            method: method,
            amount: amount,
            currency: currency,
          );
      ref.read(autoSyncCoordinatorProvider).schedulePush();
    });
  }
}

class BillingActivityRef {
  const BillingActivityRef({required this.type, required this.id});

  final BillingActivityType type;
  final String id;

  @override
  bool operator ==(Object other) {
    return other is BillingActivityRef && other.type == type && other.id == id;
  }

  @override
  int get hashCode => Object.hash(type, id);
}
