import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart' show AppRadius;
import '../../../primary_module/controllers/primary_module_providers.dart';
import '../providers/produit_providers.dart';

/// Barre de recherche de l'écran Produits — même forme, taille et couleurs
/// que la barre de recherche de l'écran principal (ModuleSearchBar).
class ProduitSearchBar extends ConsumerStatefulWidget {
  const ProduitSearchBar({super.key});

  @override
  ConsumerState<ProduitSearchBar> createState() => _ProduitSearchBarState();
}

class _ProduitSearchBarState extends ConsumerState<ProduitSearchBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    ref.read(produitSearchQueryProvider.notifier).state = '';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final primaryColor = ref.watch(primaryModuleConfigProvider).primaryColor;

    return SizedBox(
      height: 56,
      child: TextField(
        controller: _controller,
        onChanged: (value) =>
            ref.read(produitSearchQueryProvider.notifier).state = value,
        style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: l10n.searchProductPlaceholder,
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
            borderSide: BorderSide(color: primaryColor),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }
}
