import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../auth/phone_auth_mapper.dart';
import '../../domain/country_dial_code.dart';

/// Champ téléphone en deux parties : pays (indicatif) + numéro local.
class PhoneNumberField extends FormField<String> {
  PhoneNumberField({
    super.key,
    required String labelText,
    bool enabled = true,
    Key? localNumberKey,
    CountryDialCode initialCountry = SupportedCountries.senegal,
    String? Function(String? fullNumber)? validator,
    ValueChanged<String>? onFullNumberChanged,
  }) : super(
          initialValue: PhoneAuthMapper.combine(
            dialCode: initialCountry.dialCode,
            localNumber: '',
          ),
          validator: validator,
          builder: (field) {
            return _PhoneNumberFieldBody(
              field: field,
              labelText: labelText,
              enabled: enabled,
              localNumberKey: localNumberKey,
              initialCountry: initialCountry,
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
    this.localNumberKey,
    this.onFullNumberChanged,
  });

  final FormFieldState<String> field;
  final String labelText;
  final bool enabled;
  final CountryDialCode initialCountry;
  final Key? localNumberKey;
  final ValueChanged<String>? onFullNumberChanged;

  @override
  State<_PhoneNumberFieldBody> createState() => _PhoneNumberFieldBodyState();
}

class _PhoneNumberFieldBodyState extends State<_PhoneNumberFieldBody> {
  late CountryDialCode _country = widget.initialCountry;
  final _localController = TextEditingController();

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
          decoration: InputDecoration(
            labelText: widget.labelText,
            errorText: errorText,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
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
              const SizedBox(width: 8),
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
                    isDense: true,
                    hintText: '771234567',
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
    return DropdownButtonHideUnderline(
      child: DropdownButton<CountryDialCode>(
        value: value,
        isDense: true,
        onChanged: enabled
            ? (country) {
                if (country != null) onChanged(country);
              }
            : null,
        selectedItemBuilder: (_) {
          return SupportedCountries.all
              .map(
                (country) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(country.flagEmoji, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 4),
                    Text(country.displayCode),
                  ],
                ),
              )
              .toList();
        },
        items: SupportedCountries.all
            .map(
              (country) => DropdownMenuItem(
                value: country,
                child: Text(
                  '${country.flagEmoji} ${country.displayCode} ${country.name}',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
