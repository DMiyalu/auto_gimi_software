import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/business_category.dart';
import '../../establishment/presentation/providers/establishment_providers.dart';
import '../config/business_module_config.dart';
import '../config/business_module_configs.dart';
import '../models/activity_item.dart';
import '../services/mock_activity_data.dart';

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

/// Jeu de données mocké pour le métier actif — reste mutable en mémoire
/// (épinglage, changement de statut, annulation) le temps de brancher un
/// vrai repository.
final activityListProvider =
    NotifierProvider<ActivityListNotifier, List<ActivityItem>>(
  ActivityListNotifier.new,
);

class ActivityListNotifier extends Notifier<List<ActivityItem>> {
  @override
  List<ActivityItem> build() {
    final category = ref.watch(activeBusinessCategoryProvider);
    return MockActivityData.forCategory(category);
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
            statusColor: MockActivityData.statusColorFor(statusKey),
          )
        else
          item,
    ];
  }

  void cancel(String id) => setStatus(id, 'annulees', 'Annulée');
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
