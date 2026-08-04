import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/business_category.dart';
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
    final isRestaurant = config.category == BusinessCategory.restaurant;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isRestaurant ? 18 : 16),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: isRestaurant ? 56 : null,
              child: TextField(
                controller: _controller,
                onChanged: (value) =>
                    ref.read(moduleSearchQueryProvider.notifier).state = value,
                style: const TextStyle(fontSize: 16, color: Color(0xFF101529)),
                decoration: InputDecoration(
                  hintText: config.searchPlaceholder,
                  hintStyle: const TextStyle(
                    color: Color(0xFF7B819B),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF7B819B),
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
                    borderSide: const BorderSide(color: Color(0xFFE6E8EF)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.chip),
                    borderSide: BorderSide(color: config.primaryColor),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),
          ),
          if (isRestaurant) ...[
            const SizedBox(width: 14),
            SizedBox(
              height: 56,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF101529),
                  elevation: 1.5,
                  shadowColor: Colors.black.withValues(alpha: 0.14),
                  side: const BorderSide(color: Color(0xFFE6E8EF)),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                onPressed: () {},
                icon: const Icon(Icons.tune_rounded, size: 24),
                label: const Text('Filtres'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
