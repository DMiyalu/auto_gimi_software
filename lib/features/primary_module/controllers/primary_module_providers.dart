import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/business_category.dart';
import '../../../core/domain/enums.dart';
import '../../../core/theme/app_colors.dart';
import '../../establishment/presentation/providers/establishment_providers.dart';
import '../../garage/domain/entities/prestation_summary.dart';
import '../../garage/presentation/providers/prestation_providers.dart';
import '../../restaurant/domain/entities/commande_entity.dart';
import '../../restaurant/presentation/providers/commande_providers.dart';
import '../config/business_module_config.dart';
import '../config/business_module_configs.dart';
import '../models/activity_item.dart';

/// Métier actif, dérivé de l'établissement réel. `garageAuto` sert de
/// valeur par défaut le temps que l'établissement se charge.
final activeBusinessCategoryProvider = Provider<BusinessCategory>((ref) {
  final establishment = ref.watch(currentEstablishmentProvider).valueOrNull;
  return establishment?.category ?? BusinessCategory.garageAuto;
});

/// Configuration UI/UX résolue pour le métier actif — seule source de
/// vérité consultée par les widgets de l'écran principal.
final primaryModuleConfigProvider = Provider<BusinessModuleConfig>((ref) {
  final category = ref.watch(activeBusinessCategoryProvider);
  return BusinessModuleConfigs.forCategory(category);
});

/// Texte de recherche courant sur l'écran principal.
final moduleSearchQueryProvider = StateProvider<String>((ref) => '');

/// Clé du filtre de statut sélectionné ('all' par défaut).
final moduleSelectedFilterProvider = StateProvider<String>((ref) => 'all');

/// Liste d'activité issue uniquement des repositories réels du métier actif.
/// Si aucune donnée n'existe en base, l'écran reste vide.
final activityListProvider =
    NotifierProvider<ActivityListNotifier, List<ActivityItem>>(
      ActivityListNotifier.new,
    );

class ActivityListNotifier extends Notifier<List<ActivityItem>> {
  @override
  List<ActivityItem> build() {
    final category = ref.watch(activeBusinessCategoryProvider);
    if (category == BusinessCategory.garageAuto) {
      final summaries = ref.watch(prestationsSummaryProvider).valueOrNull ?? [];
      return summaries.map(_fromPrestationSummary).toList();
    }
    if (category == BusinessCategory.restaurant) {
      final commandes = ref.watch(commandesProvider).valueOrNull ?? [];
      return commandes.map(_fromCommande).toList();
    }
    return const [];
  }

  ActivityItem _fromPrestationSummary(PrestationSummary summary) {
    final isOuverte = summary.statut == PrestationStatut.ouverte;
    final statusKey = isOuverte ? 'en_cours' : 'terminees';
    // Quand marque/modèle sont inconnus, le titre retombe déjà sur
    // l'immatriculation — éviter de la répéter en sous-titre/meta.
    final titleIsImmatriculation =
        summary.vehiculeDisplayName == summary.immatriculation;
    return ActivityItem(
      id: summary.id,
      title: summary.vehiculeDisplayName,
      subtitle: summary.clientName ?? 'Client non renseigné',
      time: summary.dateOuverture,
      statusKey: statusKey,
      statusLabel: isOuverte ? 'En cours' : 'Terminée',
      statusColor: _statusColorFor(statusKey),
      leadingIcon: Icons.build_circle_outlined,
      amount: summary.montantTotal,
      metaLabel: titleIsImmatriculation ? null : summary.immatriculation,
    );
  }

  ActivityItem _fromCommande(CommandeEntity commande) {
    return ActivityItem(
      id: commande.id,
      title: commande.reference,
      subtitle: commande.context ?? 'Commande restaurant',
      time: commande.createdAt,
      statusKey: commande.statusKey,
      statusLabel: commande.statusLabel,
      statusColor: commandeStatusColor(commande.statusKey),
      leadingIcon: Icons.restaurant_outlined,
      amount: commande.totalAmount,
      metaLabel: commande.clientId == null ? null : 'Client lié',
    );
  }

  /// Épingle/désépingle une carte — les cartes épinglées remontent en tête
  /// de liste, comme une conversation épinglée sur WhatsApp.
  void togglePin(String id) {
    final updated = [
      for (final item in state)
        if (item.id == id) item.copyWith(pinned: !item.pinned) else item,
    ];
    final pinned = updated.where((item) => item.pinned).toList();
    final rest = updated.where((item) => !item.pinned).toList();
    state = [...pinned, ...rest];
  }

  void setStatus(String id, String statusKey, String statusLabel) {
    state = [
      for (final item in state)
        if (item.id == id)
          item.copyWith(
            statusKey: statusKey,
            statusLabel: statusLabel,
            statusColor: _statusColorFor(statusKey),
          )
        else
          item,
    ];
  }

  void cancel(String id) => setStatus(id, 'annulees', 'Annulée');
}

Color _statusColorFor(String key) {
  return switch (key) {
    'en_attente' => AppColors.violetClair,
    'en_preparation' ||
    'en_cours' ||
    'diagnostic' ||
    'planifiees' => AppColors.violetPrincipal,
    'pretes' || 'terminees' || 'cloturee' => AppColors.bleuRoyal,
    'livraison' || 'a_payer' => AppColors.cyan,
    'annulees' => Colors.grey,
    _ => Colors.blueGrey,
  };
}

/// Liste affichée après application de la recherche et du filtre de statut.
final filteredActivityListProvider = Provider<List<ActivityItem>>((ref) {
  final items = ref.watch(activityListProvider);
  final query = ref.watch(moduleSearchQueryProvider).trim().toLowerCase();
  final filterKey = ref.watch(moduleSelectedFilterProvider);

  return items.where((item) {
    final matchesFilter = filterKey == 'all' || item.statusKey == filterKey;
    if (!matchesFilter) return false;
    if (query.isEmpty) return true;
    return item.title.toLowerCase().contains(query) ||
        item.subtitle.toLowerCase().contains(query) ||
        (item.metaLabel?.toLowerCase().contains(query) ?? false);
  }).toList();
});
