import 'dart:convert';

import '../../../../core/domain/business_category.dart';

/// Établissement — unité d'isolation des données (tenant SaaS).
class Establishment {
  Establishment({
    required this.id,
    required this.name,
    required this.category,
    required this.ownerId,
    required this.managerName,
    required this.phone,
    required this.phoneVerified,
    required this.createdAt,
    String? mainActivity,
    this.logoBase64,
    this.invoiceHeaderLines = const [],
    this.invoiceFooterLines = const [],
  }) : mainActivity = mainActivity ?? category.defaultMainActivity;

  static const invoiceLineMaxLength = 20;
  static const invoiceLinesMaxCount = 6;

  final String id;
  final String name;
  final BusinessCategory category;
  final String ownerId;
  final String managerName;
  final String phone;
  final bool phoneVerified;
  final DateTime createdAt;
  final String mainActivity;

  /// Logo compressé (JPEG base64) pour affichage UI + impression ticket.
  final String? logoBase64;

  /// Lignes d'en-tête facture (max [invoiceLineMaxLength] caractères chacune).
  final List<String> invoiceHeaderLines;

  /// Lignes de pied de page facture (max [invoiceLineMaxLength] caractères chacune).
  final List<String> invoiceFooterLines;

  bool get hasLogo => logoBase64 != null && logoBase64!.trim().isNotEmpty;

  List<int>? get logoBytes {
    final raw = logoBase64?.trim();
    if (raw == null || raw.isEmpty) return null;
    try {
      return base64Decode(raw);
    } catch (_) {
      return null;
    }
  }

  Establishment copyWith({
    String? id,
    String? name,
    BusinessCategory? category,
    String? ownerId,
    String? managerName,
    String? phone,
    bool? phoneVerified,
    DateTime? createdAt,
    String? mainActivity,
    String? logoBase64,
    bool clearLogo = false,
    List<String>? invoiceHeaderLines,
    List<String>? invoiceFooterLines,
  }) {
    return Establishment(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      ownerId: ownerId ?? this.ownerId,
      managerName: managerName ?? this.managerName,
      phone: phone ?? this.phone,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      createdAt: createdAt ?? this.createdAt,
      mainActivity: mainActivity ?? this.mainActivity,
      logoBase64: clearLogo ? null : (logoBase64 ?? this.logoBase64),
      invoiceHeaderLines: invoiceHeaderLines ?? this.invoiceHeaderLines,
      invoiceFooterLines: invoiceFooterLines ?? this.invoiceFooterLines,
    );
  }

  static List<String> sanitizeInvoiceLines(Iterable<String> lines) {
    return lines
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .map(
          (line) => line.length <= invoiceLineMaxLength
              ? line
              : line.substring(0, invoiceLineMaxLength),
        )
        .take(invoiceLinesMaxCount)
        .toList(growable: false);
  }
}
