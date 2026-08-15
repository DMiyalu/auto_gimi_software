import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/auth_error_mapper.dart';
import '../../../../core/domain/business_category.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../establishment/presentation/providers/establishment_providers.dart';
import '../providers/commande_providers.dart';

class NewCommandeScreen extends ConsumerStatefulWidget {
  const NewCommandeScreen({super.key});

  @override
  ConsumerState<NewCommandeScreen> createState() => _NewCommandeScreenState();
}

class _NewCommandeScreenState extends ConsumerState<NewCommandeScreen> {
  static final _tableNumbers = List<int>.unmodifiable(
    List.generate(20, (index) => index + 1),
  );

  int? _selectedTable;

  Future<void> _submit() async {
    final category = ref
        .read(currentEstablishmentProvider)
        .valueOrNull
        ?.category;
    final controller = ref.read(commandeControllerProvider.notifier);
    final commandeId = await controller.createCommande(
      context: _contextFromSelection(
        _selectedTable,
        isShop: category == BusinessCategory.shop,
      ),
    );

    if (!mounted) return;
    final state = ref.read(commandeControllerProvider);
    if (!state.hasError) context.go(Routes.commandeDetailPath(commandeId));
  }

  String? _contextFromSelection(int? value, {required bool isShop}) =>
      value == null ? null : '${isShop ? 'Caisse' : 'Table'} $value';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(commandeControllerProvider);
    final canCreateActivities = ref.watch(canCreateActivitiesProvider);
    final category = ref
        .watch(currentEstablishmentProvider)
        .valueOrNull
        ?.category;
    final isShop = category == BusinessCategory.shop;
    final heroIcon = isShop
        ? Icons.storefront_outlined
        : Icons.table_restaurant_outlined;

    ref.listen(commandeControllerProvider, (_, next) {
      if (next.hasError && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AuthErrorMapper.message(next.error!))),
        );
      }
    });

    if (!canCreateActivities) {
      return Scaffold(
        appBar: AppBar(title: const Text('Accès limité')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Vous n’avez pas le droit de créer des commandes pour cet établissement.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Nouvelle commande'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    heroIcon,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Créer une commande',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    isShop
                        ? 'La caisse est optionnelle. Vous pourrez ajouter les articles et le client ensuite.'
                        : 'Le numéro de table est optionnel. Vous pourrez ajouter les produits et le client ensuite.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF707792),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _TableSelectorField(
                    selectedTable: _selectedTable,
                    isShop: isShop,
                    enabled: !state.isLoading,
                    onTap: () => _showTablePicker(context, isShop: isShop),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: state.isLoading ? null : _submit,
                    icon: state.isLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.arrow_forward_rounded),
                    label: const Text('Continuer'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showTablePicker(BuildContext context, {required bool isShop}) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.22),
      isScrollControlled: true,
      builder: (sheetContext) {
        return _TablePickerSheet(
          selectedTable: _selectedTable,
          tableNumbers: _tableNumbers,
          isShop: isShop,
          onSelected: (value) {
            setState(() => _selectedTable = value);
            Navigator.of(sheetContext).pop();
          },
        );
      },
    );
  }
}

class _TableSelectorField extends StatelessWidget {
  const _TableSelectorField({
    required this.selectedTable,
    required this.isShop,
    required this.enabled,
    required this.onTap,
  });

  final int? selectedTable;
  final bool isShop;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = selectedTable == null
        ? (isShop ? 'Sans caisse' : 'Sans table')
        : '${isShop ? 'Caisse' : 'Table'} $selectedTable';
    final icon = isShop
        ? Icons.point_of_sale_outlined
        : Icons.table_restaurant_outlined;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: enabled ? 1 : 0.55,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: enabled ? onTap : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            constraints: const BoxConstraints(minHeight: 76),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE6E8EF)),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.045),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.violetPrincipal.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppColors.violetPrincipal),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isShop ? 'Caisse' : 'Table',
                        style: TextStyle(
                          color: Color(0xFF707792),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF101529),
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF101529),
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TablePickerSheet extends StatelessWidget {
  const _TablePickerSheet({
    required this.selectedTable,
    required this.tableNumbers,
    required this.isShop,
    required this.onSelected,
  });

  final int? selectedTable;
  final List<int> tableNumbers;
  final bool isShop;
  final ValueChanged<int?> onSelected;

  @override
  Widget build(BuildContext context) {
    final options = <int?>[null, ...tableNumbers];
    final icon = isShop
        ? Icons.point_of_sale_outlined
        : Icons.table_restaurant_outlined;

    return SafeArea(
      top: false,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, (1 - value) * 22),
              child: child,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.16),
                  blurRadius: 30,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6E8EF),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.violetPrincipal.withValues(
                            alpha: 0.10,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: AppColors.violetPrincipal),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isShop
                                  ? 'Choisir une caisse'
                                  : 'Choisir une table',
                              style: TextStyle(
                                color: Color(0xFF101529),
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              isShop
                                  ? 'Associez la commande à une caisse si utile.'
                                  : '5 choix visibles, faites défiler pour la suite.',
                              style: TextStyle(
                                color: Color(0xFF707792),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    height: 320,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FC),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE6E8EF)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(8),
                        physics: const BouncingScrollPhysics(),
                        itemCount: options.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 6),
                        itemBuilder: (context, index) {
                          final table = options[index];
                          return _TableOptionTile(
                            table: table,
                            selected: table == selectedTable,
                            isShop: isShop,
                            index: index,
                            onTap: () => onSelected(table),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TableOptionTile extends StatelessWidget {
  const _TableOptionTile({
    required this.table,
    required this.selected,
    required this.isShop,
    required this.index,
    required this.onTap,
  });

  final int? table;
  final bool selected;
  final bool isShop;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = table == null
        ? (isShop ? 'Sans caisse' : 'Sans table')
        : '${isShop ? 'Caisse' : 'Table'} $table';
    final subtitle = table == null
        ? (isShop
              ? 'Pour retrait, livraison ou vente libre'
              : 'Pour livraison, à emporter ou commande libre')
        : (isShop ? 'Vente en boutique' : 'Service en salle');

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 180 + (index.clamp(0, 5) * 34)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 10),
            child: child,
          ),
        );
      },
      child: Material(
        color: selected ? AppColors.violetPrincipal : Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: SizedBox(
            height: 58,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Icon(
                    table == null
                        ? (isShop
                              ? Icons.shopping_bag_outlined
                              : Icons.more_horiz_rounded)
                        : (isShop
                              ? Icons.point_of_sale_outlined
                              : Icons.table_restaurant_outlined),
                    color: selected ? Colors.white : AppColors.violetPrincipal,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: selected
                                ? Colors.white
                                : const Color(0xFF101529),
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: selected
                                ? Colors.white.withValues(alpha: 0.78)
                                : const Color(0xFF707792),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (selected)
                    const Icon(Icons.check_circle_rounded, color: Colors.white),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
