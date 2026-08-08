import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/firebase/firebase_bootstrap.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../establishment/domain/models/establishment_role.dart';
import '../../../establishment/presentation/providers/establishment_providers.dart';
import '../../../produits/domain/entities/product_category_entity.dart';
import '../../../produits/presentation/providers/produit_providers.dart';
import '../../../restaurant/presentation/providers/commande_providers.dart';
import '../../data/disabled_restaurant_report_mail_repository.dart';
import '../../data/firebase_restaurant_report_mail_repository.dart';
import '../../data/repositories/restaurant_reporting_repository_impl.dart';
import '../../domain/entities/product_sales_item.dart';
import '../../domain/entities/report_date_range.dart';
import '../../domain/entities/restaurant_report_kpis.dart';
import '../../domain/entities/revenue_evolution_point.dart';
import '../../domain/repositories/restaurant_report_mail_repository.dart';
import '../../domain/repositories/restaurant_reporting_repository.dart';
import '../../domain/services/restaurant_report_aggregator.dart';

final restaurantReportingRepositoryProvider =
    Provider<RestaurantReportingRepository>((ref) {
      return RestaurantReportingRepositoryImpl(
        database: ref.watch(databaseProvider),
      );
    });

final restaurantReportMailRepositoryProvider =
    Provider<RestaurantReportMailRepository>((ref) {
      if (isFirebaseConfigured) {
        return FirebaseRestaurantReportMailRepository();
      }
      return DisabledRestaurantReportMailRepository();
    });

/// Envoi manuel du rapport e-mail (hebdo / mensuel).
final sendRestaurantReportProvider =
    AsyncNotifierProvider<SendRestaurantReportController, void>(
      SendRestaurantReportController.new,
    );

class SendRestaurantReportController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> send({required String kind}) async {
    final establishment = ref.read(currentEstablishmentProvider).valueOrNull;
    if (establishment == null) {
      state = AsyncError(
        StateError('Aucun établissement actif.'),
        StackTrace.current,
      );
      return;
    }

    final role = ref.read(activeEstablishmentRoleProvider);
    if (role != EstablishmentRole.owner) {
      state = AsyncError(
        StateError(
          'Seul le propriétaire peut envoyer le rapport par e-mail.',
        ),
        StackTrace.current,
      );
      return;
    }

    final profile = ref.read(userProfileProvider).valueOrNull;
    if (profile == null || !profile.hasReportEmail) {
      state = AsyncError(
        StateError(
          'Ajoutez votre e-mail dans le profil pour recevoir le rapport.',
        ),
        StackTrace.current,
      );
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      try {
        await ref
            .read(restaurantReportMailRepositoryProvider)
            .sendReport(
              establishmentId: establishment.id,
              kind: kind,
            );
      } on FirebaseFunctionsException catch (error) {
        throw StateError(_functionsMessage(error));
      }
    });
  }

  static String _functionsMessage(FirebaseFunctionsException error) {
    final details = error.message?.trim();
    if (details != null && details.isNotEmpty) return details;
    return switch (error.code) {
      'failed-precondition' =>
        'Aucun e-mail envoyé. Vérifiez l’e-mail du propriétaire.',
      'permission-denied' =>
        'Seul le propriétaire peut envoyer le rapport.',
      'unauthenticated' => 'Authentification requise.',
      _ => 'Échec de l’envoi du rapport (${error.code}).',
    };
  }
}

/// Période active de l'écran Rapports (défaut : aujourd'hui).
final reportDateRangeProvider =
    NotifierProvider<ReportDateRangeNotifier, ReportDateRange>(
      ReportDateRangeNotifier.new,
    );

class ReportDateRangeNotifier extends Notifier<ReportDateRange> {
  @override
  ReportDateRange build() => ReportDateRange.today();

  void setPreset(ReportPeriodPreset preset) {
    state = switch (preset) {
      ReportPeriodPreset.today => ReportDateRange.today(),
      ReportPeriodPreset.yesterday => ReportDateRange.yesterday(),
      ReportPeriodPreset.last7Days => ReportDateRange.last7Days(),
      ReportPeriodPreset.last30Days => ReportDateRange.last30Days(),
      ReportPeriodPreset.custom => state,
    };
  }

  void setCustomRange({required DateTime start, required DateTime end}) {
    state = ReportDateRange.custom(start: start, end: end);
  }
}

/// Catégorie produit sélectionnée pour la répartition (`null` = première).
final selectedReportCategoryIdProvider = StateProvider<String?>((ref) => null);

final restaurantReportKpisProvider = Provider<AsyncValue<RestaurantReportKpis>>(
  (ref) {
    final range = ref.watch(reportDateRangeProvider);
    final commandesAsync = ref.watch(commandesProvider);
    return commandesAsync.whenData(
      (commandes) => RestaurantReportAggregator.computeKpis(
        commandes: commandes,
        range: range,
      ),
    );
  },
);

final revenueEvolutionProvider =
    Provider<AsyncValue<List<RevenueEvolutionPoint>>>((ref) {
      final range = ref.watch(reportDateRangeProvider);
      final commandesAsync = ref.watch(commandesProvider);
      return commandesAsync.whenData(
        (commandes) => RestaurantReportAggregator.computeRevenueEvolution(
          commandes: commandes,
          range: range,
        ),
      );
    });

/// Catégorie effective : sélection utilisateur, sinon première de la liste.
final effectiveReportCategoryProvider =
    Provider<AsyncValue<ProductCategoryEntity?>>((ref) {
      final selectedId = ref.watch(selectedReportCategoryIdProvider);
      final categoriesAsync = ref.watch(productCategoriesProvider);

      return categoriesAsync.whenData((categories) {
        if (categories.isEmpty) return null;
        if (selectedId != null) {
          for (final category in categories) {
            if (category.id == selectedId) return category;
          }
        }
        return categories.first;
      });
    });

final topProductSalesProvider =
    StreamProvider<List<ProductSalesItem>>((ref) {
      return _watchProductSales(ref, limit: 5);
    });

final allProductSalesProvider =
    StreamProvider<List<ProductSalesItem>>((ref) {
      return _watchProductSales(ref, limit: null);
    });

Stream<List<ProductSalesItem>> _watchProductSales(
  Ref ref, {
  required int? limit,
}) {
  final establishment = ref.watch(currentEstablishmentProvider).valueOrNull;
  if (establishment == null) return Stream.value(const []);

  // Attendre les catégories pour filtrer sur la catégorie effective
  // (évite un flash "toutes catégories" avant la première).
  final categoriesAsync = ref.watch(productCategoriesProvider);
  if (categoriesAsync.isLoading) {
    return Stream.value(const []);
  }

  final range = ref.watch(reportDateRangeProvider);
  final categoryId = ref.watch(effectiveReportCategoryProvider).valueOrNull?.id;

  return ref
      .watch(restaurantReportingRepositoryProvider)
      .watchProductSales(
        establishmentId: establishment.id,
        range: range,
        categoryId: categoryId,
        limit: limit,
      );
}
