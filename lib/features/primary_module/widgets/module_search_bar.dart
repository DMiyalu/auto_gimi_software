import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../controllers/primary_module_providers.dart';

/// Barre de recherche instantanée. Le placeholder vient entièrement de la
/// configuration métier active — jamais codé en dur ici.
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
    final usesRestaurantWorkflow = config.category.usesRestaurantWorkflow;
    final radius = usesRestaurantWorkflow ? 16.0 : AppRadius.chip;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: SizedBox(
        height: usesRestaurantWorkflow ? 52 : 56,
        child: TextField(
          controller: _controller,
          onChanged: (value) =>
              ref.read(moduleSearchQueryProvider.notifier).state = value,
          style: TextStyle(
            fontSize: 16,
            color: usesRestaurantWorkflow
                ? AppColors.zuriNavy
                : AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: config.searchPlaceholder,
            hintStyle: TextStyle(
              color: AppColors.textMuted,
              fontSize: usesRestaurantWorkflow ? 15 : 16,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: AppColors.textMuted,
              size: usesRestaurantWorkflow ? 24 : 28,
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
              borderRadius: BorderRadius.circular(radius),
              borderSide: const BorderSide(color: AppColors.borderSubtle),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: BorderSide(color: config.primaryColor, width: 1.4),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 0),
          ),
        ),
      ),
    );
  }
}
