import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../auth/phone_auth_mapper.dart';
import '../../domain/country_dial_code.dart';
import '../../theme/app_colors.dart';
import '../../../features/auth/presentation/widgets/auth_brand_chrome.dart';

/// Champ téléphone en deux parties : pays (indicatif) + numéro local.
class PhoneNumberField extends FormField<String> {
  PhoneNumberField({
    super.key,
    required String labelText,
    bool enabled = true,
    Key? localNumberKey,
    CountryDialCode initialCountry = SupportedCountries.senegal,
    String? initialValue,
    super.validator,
    ValueChanged<String>? onFullNumberChanged,
  }) : super(
         initialValue:
             initialValue ??
             PhoneAuthMapper.combine(
               dialCode: initialCountry.dialCode,
               localNumber: '',
             ),
         builder: (field) {
           return _PhoneNumberFieldBody(
             field: field,
             labelText: labelText,
             enabled: enabled,
             localNumberKey: localNumberKey,
             initialCountry: initialCountry,
             initialFullNumber: initialValue,
             onFullNumberChanged: onFullNumberChanged,
           );
         },
       );
}

class _PhoneNumberFieldBody extends StatefulWidget {
  const _PhoneNumberFieldBody({
    required this.field,
    required this.labelText,
    required this.enabled,
    required this.initialCountry,
    this.initialFullNumber,
    this.localNumberKey,
    this.onFullNumberChanged,
  });

  final FormFieldState<String> field;
  final String labelText;
  final bool enabled;
  final CountryDialCode initialCountry;
  final String? initialFullNumber;
  final Key? localNumberKey;
  final ValueChanged<String>? onFullNumberChanged;

  @override
  State<_PhoneNumberFieldBody> createState() => _PhoneNumberFieldBodyState();
}

class _PhoneNumberFieldBodyState extends State<_PhoneNumberFieldBody> {
  late CountryDialCode _country = widget.initialCountry;
  final _localController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final fullNumber = widget.initialFullNumber;
    if (fullNumber != null && fullNumber.isNotEmpty) {
      final digits = PhoneAuthMapper.normalize(fullNumber);
      final matches =
          SupportedCountries.all
              .where((country) => digits.startsWith(country.dialCode))
              .toList()
            ..sort((a, b) => b.dialCode.length.compareTo(a.dialCode.length));
      if (matches.isNotEmpty) {
        _country = matches.first;
        _localController.text = digits.substring(_country.dialCode.length);
      } else {
        _localController.text = digits;
      }
    }
  }

  @override
  void dispose() {
    _localController.dispose();
    super.dispose();
  }

  String get _fullNumber => PhoneAuthMapper.combine(
    dialCode: _country.dialCode,
    localNumber: _localController.text,
  );

  void _notifyChange() {
    final fullNumber = _fullNumber;
    widget.field.didChange(fullNumber);
    widget.onFullNumberChanged?.call(fullNumber);
  }

  @override
  Widget build(BuildContext context) {
    final errorText = widget.field.errorText;

    return InputDecorator(
      decoration:
          authFieldDecoration(
            labelText: widget.labelText,
            prefixIcon: Icons.phone_outlined,
          ).copyWith(
            errorText: errorText,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 15,
            ),
          ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _CountrySelector(
            value: _country,
            enabled: widget.enabled,
            onChanged: (country) {
              setState(() => _country = country);
              _notifyChange();
            },
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              key: widget.localNumberKey,
              controller: _localController,
              enabled: widget.enabled,
              keyboardType: TextInputType.phone,
              autofillHints: const [AutofillHints.telephoneNumber],
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                hintText: '771234567',
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(
                color: AppColors.zuriNavy,
                fontWeight: FontWeight.w700,
              ),
              onChanged: (_) => _notifyChange(),
            ),
          ),
        ],
      ),
    );
  }
}

class _CountrySelector extends StatelessWidget {
  const _CountrySelector({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final CountryDialCode value;
  final bool enabled;
  final ValueChanged<CountryDialCode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: enabled ? () => _showCountryPicker(context) : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(value.flagEmoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 5),
              Text(
                value.displayCode,
                style: const TextStyle(
                  color: AppColors.zuriNavy,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 2),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF8A90A5),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showCountryPicker(BuildContext context) async {
    final selected = await showModalBottomSheet<CountryDialCode>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.22),
      isScrollControlled: true,
      builder: (_) => _CountryPickerSheet(selectedCountry: value),
    );
    if (selected != null) onChanged(selected);
  }
}

class _CountryPickerSheet extends StatefulWidget {
  const _CountryPickerSheet({required this.selectedCountry});

  final CountryDialCode selectedCountry;

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final filtered = SupportedCountries.all.where((country) {
      return query.isEmpty ||
          country.name.toLowerCase().contains(query) ||
          country.displayCode.contains(query) ||
          country.dialCode.contains(query);
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
                'Code pays',
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
                decoration: authFieldDecoration(
                  labelText: 'Rechercher',
                  prefixIcon: Icons.search_rounded,
                ),
              ),
              const SizedBox(height: 10),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) =>
                      const Divider(height: 1, color: Color(0xFFE8EAF0)),
                  itemBuilder: (context, index) {
                    final country = filtered[index];
                    final selected = country == widget.selectedCountry;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Text(
                        country.flagEmoji,
                        style: const TextStyle(fontSize: 22),
                      ),
                      title: Text(
                        country.name,
                        style: const TextStyle(
                          color: AppColors.zuriNavy,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      subtitle: Text(country.displayCode),
                      trailing: selected
                          ? const Icon(
                              Icons.check_rounded,
                              color: AppColors.zuriRed,
                            )
                          : null,
                      onTap: () => Navigator.of(context).pop(country),
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
