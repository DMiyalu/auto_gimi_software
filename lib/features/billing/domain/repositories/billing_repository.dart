import '../../../../core/domain/app_currency.dart';
import '../entities/facture_entity.dart';
import '../entities/paiement_entity.dart';

abstract class BillingRepository {
  Stream<List<FactureEntity>> watchFactures({required String establishmentId});

  Stream<FactureEntity?> watchFactureForActivity({
    required String establishmentId,
    required BillingActivityType activityType,
    required String activityId,
  });

  Stream<List<PaiementEntity>> watchPaiements({
    required String establishmentId,
    required String factureId,
  });

  Future<FactureEntity> issueFactureForActivity({
    required String establishmentId,
    required BillingActivityType activityType,
    required String activityId,
    required double totalAmount,
    AppCurrency currency = AppCurrency.usd,
  });

  Future<PaiementEntity> recordPayment({
    required String establishmentId,
    required String factureId,
    required PaymentMethod method,
    required double amount,
    AppCurrency currency = AppCurrency.usd,
  });
}
