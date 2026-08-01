import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/routing/routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../establishment/presentation/providers/establishment_providers.dart';
import '../controllers/primary_module_providers.dart';

/// En-tête réutilisable pour tous les métiers : identité de l'établissement,
/// sélecteur d'établissement (préparé, inerte pour l'instant), notifications
/// et avatar utilisateur.
class BusinessHeader extends ConsumerWidget {
  const BusinessHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final establishment = ref.watch(currentEstablishmentProvider).valueOrNull;
    final config = ref.watch(primaryModuleConfigProvider);
    final l10n = AppLocalizations.of(context);

    final name = establishment?.name ?? '…';
    final initials = (establishment?.managerName.isNotEmpty ?? false)
        ? establishment!.managerName[0].toUpperCase()
        : '?';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.xs,
        AppSpacing.sm,
        AppSpacing.xs,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: config.primaryColor.withValues(alpha: 0.12),
            child: Icon(config.activityIcon, color: config.primaryColor),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.card),
              onTap: () => _showEstablishmentSwitcher(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            style: Theme.of(context).textTheme.titleLarge,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_down, size: 20),
                      ],
                    ),
                    if (establishment != null)
                      Text(
                        establishment.category.label(l10n),
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const _NotificationBell(),
          const SizedBox(width: AppSpacing.xs),
          GestureDetector(
            onTap: () => context.go(Routes.settings),
            child: CircleAvatar(
              radius: 20,
              child: Text(initials),
            ),
          ),
        ],
      ),
    );
  }

  void _showEstablishmentSwitcher(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Changement d’établissement — bientôt disponible'),
      ),
    );
  }
}

class _NotificationBell extends StatelessWidget {
  const _NotificationBell();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_none_outlined),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Notifications — bientôt disponible'),
              ),
            );
          },
        ),
        Positioned(
          right: 6,
          top: 6,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error,
              shape: BoxShape.circle,
            ),
            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
            child: const Text(
              '3',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 10),
            ),
          ),
        ),
      ],
    );
  }
}
