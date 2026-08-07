import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../primary_module/controllers/primary_module_providers.dart';
import '../providers/client_providers.dart';

/// Filtres rapides de l'écran Clients — même UI/UX que les filtres de
/// l'écran principal (chips horizontaux défilants), mais avec des options
/// fixes indépendantes du métier actif.
class ClientFilters extends ConsumerWidget {
  const ClientFilters({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final primaryColor = ref.watch(primaryModuleConfigProvider).primaryColor;
    final selected = ref.watch(clientListFilterProvider);

    final options = <(ClientListFilter, String)>[
      (ClientListFilter.all, l10n.clientFilterAll),
      (ClientListFilter.fideles, l10n.clientFilterLoyal),
      (ClientListFilter.nouveaux, l10n.clientFilterNew),
      (ClientListFilter.actifsCeMois, l10n.clientFilterActiveThisMonth),
      (ClientListFilter.inactifs, l10n.clientFilterInactive),
    ];

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        itemCount: options.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (key, label) = options[index];
          final isSelected = selected == key;
          return FilterChip(
            selected: isSelected,
            showCheckmark: false,
            onSelected: (_) =>
                ref.read(clientListFilterProvider.notifier).state = key,
            labelPadding: const EdgeInsets.symmetric(horizontal: 6),
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 12),
            backgroundColor: AppColors.chipBackground,
            selectedColor: primaryColor,
            shape: const StadiumBorder(side: BorderSide.none),
            label: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          );
        },
      ),
    );
  }
}
