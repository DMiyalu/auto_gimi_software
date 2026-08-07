import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../controllers/primary_module_providers.dart';

/// Barre de recherche instantanée. Le placeholder vient entièrement de la
/// configuration métier active — jamais codé en dur ici. Même forme, taille
/// et couleurs sur tous les écrans de l'app (Clients, Produits inclus).
class ModuleSearchBar extends ConsumerStatefulWidget {
  const ModuleSearchBar({super.key});

  @override
  ConsumerState<ModuleSearchBar> createState() => _ModuleSearchBarState();
}

class _ModuleSearchBarState extends ConsumerState<ModuleSearchBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    ref.read(moduleSearchQueryProvider.notifier).state = '';
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(primaryModuleConfigProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: SizedBox(
        height: 56,
        child: TextField(
          controller: _controller,
          onChanged: (value) =>
              ref.read(moduleSearchQueryProvider.notifier).state = value,
          style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: config.searchPlaceholder,
            hintStyle: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: AppColors.textMuted,
              size: 28,
            ),
            suffixIcon: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _controller,
              builder: (context, value, _) {
                if (value.text.isEmpty) return const SizedBox.shrink();
                return IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _clear,
                );
              },
            ),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.chip),
              borderSide: const BorderSide(color: AppColors.borderSubtle),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.chip),
              borderSide: BorderSide(color: config.primaryColor),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 0),
          ),
        ),
      ),
    );
  }
}
