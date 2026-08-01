import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: TextField(
        controller: _controller,
        onChanged: (value) =>
            ref.read(moduleSearchQueryProvider.notifier).state = value,
        decoration: InputDecoration(
          hintText: config.searchPlaceholder,
          prefixIcon: const Icon(Icons.search),
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
          fillColor: Theme.of(context).colorScheme.surfaceContainerLow,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.chip),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }
}
