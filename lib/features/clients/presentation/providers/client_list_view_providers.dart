import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/client_tier.dart';
import '../../../garage/presentation/providers/prestation_providers.dart';
import '../../domain/entities/client_entity.dart';
import 'client_providers.dart';

/// Clients après recherche + filtre rapide. "Actifs ce mois" / "Inactifs"
/// dépendent de la dernière commande — le garage est le seul métier avec une
/// verticale transactionnelle réelle aujourd'hui, comme pour l'onglet
/// historique de ClientDetailScreen : les autres métiers retombent sur
/// "aucune commande" tant que Commandes/Collectes n'existent pas.
final filteredClientsProvider = Provider<List<ClientEntity>>((ref) {
  final clients = ref.watch(clientsProvider).valueOrNull ?? [];
  final query = ref.watch(clientSearchQueryProvider).trim().toLowerCase();
  final filter = ref.watch(clientListFilterProvider);
  final stats = ref.watch(clientOrderStatsProvider).valueOrNull ?? {};
  final now = DateTime.now();

  return clients.where((client) {
    if (query.isNotEmpty &&
        !client.name.toLowerCase().contains(query) &&
        !client.displayPhone.toLowerCase().contains(query)) {
      return false;
    }

    final lastOrderAt = stats[client.id]?.lastOrderAt;
    final isActiveThisMonth =
        lastOrderAt != null &&
        lastOrderAt.year == now.year &&
        lastOrderAt.month == now.month;

    return switch (filter) {
      ClientListFilter.all => true,
      ClientListFilter.fideles =>
        ClientTier.forPoints(client.loyaltyPoints) != ClientTier.none,
      ClientListFilter.nouveaux =>
        now.difference(client.createdAt) <= const Duration(days: 30),
      ClientListFilter.actifsCeMois => isActiveThisMonth,
      ClientListFilter.inactifs => !isActiveThisMonth,
    };
  }).toList();
});
