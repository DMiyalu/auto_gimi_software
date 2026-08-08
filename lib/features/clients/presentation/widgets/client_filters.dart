import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/client_providers.dart';

/// Filtres rapides Clients — chips Zuri (actif = rouge).
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
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        itemCount: options.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (key, label) = options[index];
          final isSelected = selected == key;
          return Material(
            key: Key('client_filter_${key.name}'),
            color: isSelected ? AppColors.zuriRed : AppColors.zuriWhite,
            borderRadius: BorderRadius.circular(22),
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () =>
                  ref.read(clientListFilterProvider.notifier).state = key,
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.zuriRed
                        : const Color(0xFFE6E8EF),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.zuriWhite
                          : AppColors.zuriNavy,
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
