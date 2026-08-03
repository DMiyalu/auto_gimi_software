import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_spacing.dart' show AppRadius;
import '../providers/client_providers.dart';

/// Barre de recherche de l'écran Clients — même comportement et même forme
/// pilule que la barre de recherche de l'écran principal.
class ClientSearchBar extends ConsumerStatefulWidget {
  const ClientSearchBar({super.key});

  @override
  ConsumerState<ClientSearchBar> createState() => _ClientSearchBarState();
}

class _ClientSearchBarState extends ConsumerState<ClientSearchBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    ref.read(clientSearchQueryProvider.notifier).state = '';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return TextField(
      controller: _controller,
      onChanged: (value) =>
          ref.read(clientSearchQueryProvider.notifier).state = value,
      decoration: InputDecoration(
        hintText: l10n.searchClientPlaceholder,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: _controller,
          builder: (context, value, _) {
            if (value.text.isEmpty) return const SizedBox.shrink();
            return IconButton(icon: const Icon(Icons.close), onPressed: _clear);
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
    );
  }
}
