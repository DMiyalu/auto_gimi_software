import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/produit_providers.dart';

/// Barre de recherche Produits — style Zuri.
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

    return SizedBox(
      height: 52,
      child: TextField(
        controller: _controller,
        onChanged: (value) =>
            ref.read(produitSearchQueryProvider.notifier).state = value,
        style: const TextStyle(fontSize: 15, color: AppColors.zuriNavy),
        decoration: InputDecoration(
          hintText: l10n.searchProductPlaceholder,
          hintStyle: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.textMuted,
            size: 24,
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
          fillColor: AppColors.zuriWhite,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.borderSubtle),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.zuriRed, width: 1.4),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }
}
