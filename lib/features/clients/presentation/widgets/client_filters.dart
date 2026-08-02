import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_spacing.dart';
import '../providers/client_providers.dart';

/// Filtres rapides de l'écran Clients — même UI/UX que les filtres de
/// l'écran principal (chips horizontaux défilants), mais avec des options
/// fixes indépendantes du métier actif.
class ClientFilters extends ConsumerWidget {
  const ClientFilters({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selected = ref.watch(clientListFilterProvider);

    final options = <(ClientListFilter, String)>[
      (ClientListFilter.all, l10n.clientFilterAll),
      (ClientListFilter.fideles, l10n.clientFilterLoyal),
      (ClientListFilter.nouveaux, l10n.clientFilterNew),
      (ClientListFilter.actifsCeMois, l10n.clientFilterActiveThisMonth),
      (ClientListFilter.inactifs, l10n.clientFilterInactive),
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        itemCount: options.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
        itemBuilder: (context, index) {
          final (key, label) = options[index];
          return ChoiceChip(
            label: Text(label),
            selected: selected == key,
            onSelected: (_) =>
                ref.read(clientListFilterProvider.notifier).state = key,
          );
        },
      ),
    );
  }
}
