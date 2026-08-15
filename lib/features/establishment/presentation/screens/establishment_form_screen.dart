import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/auth/auth_error_mapper.dart';
import '../../../../core/domain/business_category.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../providers/establishment_providers.dart';
import '../utils/establishment_logo_codec.dart';

class EstablishmentFormScreen extends ConsumerStatefulWidget {
  const EstablishmentFormScreen({super.key});

  @override
  ConsumerState<EstablishmentFormScreen> createState() =>
      _EstablishmentFormScreenState();
}

class _EstablishmentFormScreenState
    extends ConsumerState<EstablishmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _establishmentNameController = TextEditingController();
  BusinessCategory _category = BusinessCategory.restaurant;
  String? _logoBase64;

  @override
  void dispose() {
    _establishmentNameController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (file == null) return;

    try {
      final bytes = await file.readAsBytes();
      final encoded = EstablishmentLogoCodec.encodeForStorage(bytes);
      if (!mounted) return;
      setState(() => _logoBase64 = encoded);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AuthErrorMapper.message(error))));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final profile = ref.read(userProfileProvider).valueOrNull;
    await ref
        .read(establishmentControllerProvider.notifier)
        .createOwnedEstablishment(
          category: _category,
          establishmentName: _establishmentNameController.text,
          managerName: profile?.fullName ?? '',
          phone: profile?.phone ?? '',
          logoBase64: _logoBase64,
        );

    if (!mounted) return;
    final state = ref.read(establishmentControllerProvider);
    if (!state.hasError) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(establishmentControllerProvider);
    final l10n = AppLocalizations.of(context);

    ref.listen(establishmentControllerProvider, (_, next) {
      if (next.hasError && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AuthErrorMapper.message(next.error!))),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.zuriWhite,
      appBar: AppBar(
        title: const Text('Nouvel établissement'),
        backgroundColor: AppColors.zuriWhite,
        foregroundColor: AppColors.zuriNavy,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.add_business_outlined,
                      size: 62,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Créer un établissement',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: AppColors.zuriNavy,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    const Text(
                      'Renseignez l’activité, le nom et ajoutez un logo si vous en avez un.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF707792),
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _CategorySelectorField(
                      label: _category.label(l10n),
                      icon: _category.icon,
                      enabled: !state.isLoading,
                      onTap: () => _showCategoryPicker(context, l10n),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _establishmentNameController,
                      enabled: !state.isLoading,
                      decoration: _inputDecoration(
                        label: 'Nom de l’établissement',
                      ),
                      textCapitalization: TextCapitalization.words,
                      style: const TextStyle(
                        color: AppColors.zuriNavy,
                        fontWeight: FontWeight.w700,
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Nom de l’établissement'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    _LogoSelectorField(
                      logoBase64: _logoBase64,
                      enabled: !state.isLoading,
                      onPick: _pickLogo,
                      onRemove: () => setState(() => _logoBase64 = null),
                    ),
                    const SizedBox(height: 28),
                    FilledButton(
                      onPressed: state.isLoading ? null : _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.zuriRed,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.zuriRed.withValues(
                          alpha: 0.42,
                        ),
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      child: state.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Créer l’établissement'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showCategoryPicker(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.22),
      isScrollControlled: true,
      builder: (sheetContext) {
        return _CategoryPickerSheet(
          selectedCategory: _category,
          categories: BusinessCategory.values,
          labelFor: (category) => category.label(l10n),
          onSelected: (value) {
            setState(() => _category = value);
            Navigator.of(sheetContext).pop();
          },
        );
      },
    );
  }
}

InputDecoration _inputDecoration({required String label}) {
  return InputDecoration(
    labelText: label,
    filled: true,
    fillColor: Colors.white,
    labelStyle: const TextStyle(
      color: AppColors.zuriNavy,
      fontWeight: FontWeight.w700,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: AppColors.borderSubtle),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: AppColors.borderSubtle),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: AppColors.zuriRed, width: 1.3),
    ),
  );
}

class _CategorySelectorField extends StatelessWidget {
  const _CategorySelectorField({
    required this.label,
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
            constraints: const BoxConstraints(minHeight: 76),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderSubtle),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.zuriRed, size: 25),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Catégorie d’activité',
                        style: TextStyle(
                          color: Color(0xFF8A90A5),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.zuriNavy,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF8A90A5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryPickerSheet extends StatefulWidget {
  const _CategoryPickerSheet({
    required this.selectedCategory,
    required this.categories,
    required this.labelFor,
    required this.onSelected,
  });

  final BusinessCategory selectedCategory;
  final List<BusinessCategory> categories;
  final String Function(BusinessCategory) labelFor;
  final ValueChanged<BusinessCategory> onSelected;

  @override
  State<_CategoryPickerSheet> createState() => _CategoryPickerSheetState();
}

class _CategoryPickerSheetState extends State<_CategoryPickerSheet> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final filtered = widget.categories.where((category) {
      return query.isEmpty ||
          widget.labelFor(category).toLowerCase().contains(query);
    }).toList();

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD5D8E2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Catégorie d’activité',
                style: TextStyle(
                  color: AppColors.zuriNavy,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: _inputDecoration(label: 'Rechercher'),
              ),
              const SizedBox(height: 10),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) =>
                      const Divider(height: 1, color: AppColors.borderSubtle),
                  itemBuilder: (context, index) {
                    final category = filtered[index];
                    final selected = category == widget.selectedCategory;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(category.icon, color: AppColors.zuriRed),
                      title: Text(
                        widget.labelFor(category),
                        style: const TextStyle(
                          color: AppColors.zuriNavy,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      trailing: selected
                          ? const Icon(
                              Icons.check_rounded,
                              color: AppColors.zuriRed,
                            )
                          : null,
                      onTap: () => widget.onSelected(category),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoSelectorField extends StatelessWidget {
  const _LogoSelectorField({
    required this.logoBase64,
    required this.enabled,
    required this.onPick,
    required this.onRemove,
  });

  final String? logoBase64;
  final bool enabled;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final hasLogo = logoBase64 != null && logoBase64!.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.borderSubtle),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          _LogoPreview(logoBase64: logoBase64),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Logo',
                  style: TextStyle(
                    color: AppColors.zuriNavy,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  hasLogo ? 'Logo sélectionné' : 'Optionnel',
                  style: const TextStyle(
                    color: Color(0xFF8A90A5),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: hasLogo ? 'Changer le logo' : 'Sélectionner un logo',
            onPressed: enabled ? onPick : null,
            icon: const Icon(Icons.upload_file_rounded),
            color: AppColors.zuriRed,
          ),
          if (hasLogo)
            IconButton(
              tooltip: 'Retirer le logo',
              onPressed: enabled ? onRemove : null,
              icon: const Icon(Icons.close_rounded),
              color: const Color(0xFF8A90A5),
            ),
        ],
      ),
    );
  }
}

class _LogoPreview extends StatelessWidget {
  const _LogoPreview({required this.logoBase64});

  final String? logoBase64;

  @override
  Widget build(BuildContext context) {
    final raw = logoBase64?.trim();
    Widget child = const Icon(
      Icons.image_outlined,
      color: AppColors.zuriRed,
      size: 26,
    );

    if (raw != null && raw.isNotEmpty) {
      try {
        child = ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(
            base64Decode(raw),
            fit: BoxFit.cover,
            width: 54,
            height: 54,
          ),
        );
      } catch (_) {
        child = const Icon(
          Icons.broken_image_outlined,
          color: AppColors.zuriRed,
          size: 26,
        );
      }
    }

    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: AppColors.zuriPink.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(child: child),
    );
  }
}
