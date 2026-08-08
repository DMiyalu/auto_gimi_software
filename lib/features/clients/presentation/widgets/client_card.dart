import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../garage/domain/entities/client_order_stats.dart';
import '../../domain/entities/client_entity.dart';
import 'client_avatar.dart';

/// Carte client — maquette Zuri : avatar, identité, dernière commande, chevron.
class ClientCard extends StatelessWidget {
  const ClientCard({super.key, required this.client, required this.stats});

  final ClientEntity client;
  final ClientOrderStats? stats;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lastOrderLabel = stats == null
        ? l10n.noOrdersYet
        : l10n.lastOrderAgo(_relativeWhen(l10n, stats!.lastOrderAt));

    return Material(
      color: AppColors.zuriWhite,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push(Routes.clientDetailPath(client.id)),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.zuriWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEDEFF5)),
            boxShadow: [
              BoxShadow(
                color: AppColors.zuriNavy.withValues(alpha: 0.05),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                ClientAvatar(client: client),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        client.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.zuriNavy,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        client.displayPhone,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.zuriNavy,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 13,
                            color: Color(0xFF8A90A5),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              lastOrderLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF8A90A5),
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.zuriRed,
                  size: 26,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _relativeWhen(AppLocalizations l10n, DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    final diff = today.difference(day).inDays;
    if (diff <= 0) return l10n.relativeToday;
    if (diff == 1) return l10n.relativeYesterday;
    if (diff < 14) return l10n.relativeDaysAgo(diff);
    return l10n.relativeWeeksAgo((diff / 7).floor().clamp(1, 99));
  }
}
