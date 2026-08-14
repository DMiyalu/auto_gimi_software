import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../core/domain/app_currency.dart';
import '../../domain/entities/produit_entity.dart';

class DailyMenuPdfBuilder {
  const DailyMenuPdfBuilder();

  Future<Uint8List> build({
    required String establishmentName,
    required List<ProduitEntity> products,
    DateTime? date,
  }) async {
    final menuDate = date ?? DateTime.now();
    final grouped = _groupByCategory(products);
    final document = pw.Document();

    document.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          margin: const pw.EdgeInsets.all(32),
          theme: pw.ThemeData.withFont(
            base: pw.Font.helvetica(),
            bold: pw.Font.helveticaBold(),
          ),
        ),
        build: (context) => [
          _Header(
            establishmentName: establishmentName,
            dateLabel: _formatDate(menuDate),
          ),
          pw.SizedBox(height: 24),
          for (final entry in grouped.entries) ...[
            _SectionTitle(entry.key),
            pw.SizedBox(height: 8),
            for (final product in entry.value) _ProductRow(product),
            pw.SizedBox(height: 18),
          ],
          pw.Divider(color: PdfColor.fromHex('#E7E9F1')),
          pw.SizedBox(height: 8),
          pw.Text(
            'Menu genere par Zuri',
            style: pw.TextStyle(
              color: PdfColor.fromHex('#8A90A5'),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );

    return document.save();
  }

  Map<String, List<ProduitEntity>> _groupByCategory(List<ProduitEntity> items) {
    final sorted = [...items]
      ..sort((a, b) {
        final byCategory = (a.categoryName ?? 'Sans categorie')
            .toLowerCase()
            .compareTo((b.categoryName ?? 'Sans categorie').toLowerCase());
        if (byCategory != 0) return byCategory;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

    final grouped = <String, List<ProduitEntity>>{};
    for (final product in sorted) {
      final category = product.categoryName ?? 'Sans categorie';
      grouped.putIfAbsent(category, () => []).add(product);
    }
    return grouped;
  }

  static String _formatDate(DateTime date) {
    const weekdays = [
      'Lundi',
      'Mardi',
      'Mercredi',
      'Jeudi',
      'Vendredi',
      'Samedi',
      'Dimanche',
    ];
    const months = [
      'janvier',
      'fevrier',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'aout',
      'septembre',
      'octobre',
      'novembre',
      'decembre',
    ];
    return '${weekdays[date.weekday - 1]} ${date.day} '
        '${months[date.month - 1]} ${date.year}';
  }

  static String formatAmount(double value) {
    final fixed = value % 1 == 0
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(2);
    final parts = fixed.split('.');
    final buffer = StringBuffer();
    final whole = parts.first;
    for (var index = 0; index < whole.length; index++) {
      final fromEnd = whole.length - index;
      buffer.write(whole[index]);
      if (fromEnd > 1 && fromEnd % 3 == 1) buffer.write(' ');
    }
    if (parts.length > 1) {
      buffer.write(',');
      buffer.write(parts.last);
    }
    return buffer.toString();
  }
}

class _Header extends pw.StatelessWidget {
  _Header({required this.establishmentName, required this.dateLabel});

  final String establishmentName;
  final String dateLabel;

  @override
  pw.Widget build(pw.Context context) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(22),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#9B1C31'),
        borderRadius: pw.BorderRadius.circular(14),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            establishmentName,
            style: pw.TextStyle(
              color: PdfColors.white,
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Menu du jour',
            style: pw.TextStyle(
              color: PdfColors.white,
              fontSize: 34,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            dateLabel,
            style: pw.TextStyle(
              color: PdfColor.fromHex('#FFE3EA'),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends pw.StatelessWidget {
  _SectionTitle(this.label);

  final String label;

  @override
  pw.Widget build(pw.Context context) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#FFF0F3'),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Text(
        label,
        style: pw.TextStyle(
          color: PdfColor.fromHex('#1B2744'),
          fontSize: 14,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }
}

class _ProductRow extends pw.StatelessWidget {
  _ProductRow(this.product);

  final ProduitEntity product;

  @override
  pw.Widget build(pw.Context context) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 9),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColor.fromHex('#E7E9F1')),
        ),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Text(
              product.name,
              style: pw.TextStyle(
                color: PdfColor.fromHex('#1B2744'),
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Text(
            _priceLabel(product.price, product.currency),
            style: pw.TextStyle(
              color: PdfColor.fromHex('#9B1C31'),
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  static String _priceLabel(double price, AppCurrency currency) {
    return '${DailyMenuPdfBuilder.formatAmount(price)} '
        '${currency.symbol}';
  }
}
