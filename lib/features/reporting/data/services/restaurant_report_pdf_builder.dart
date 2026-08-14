import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../domain/entities/product_sales_item.dart';
import '../../domain/entities/report_date_range.dart';
import '../../domain/entities/restaurant_report_kpis.dart';
import '../../domain/entities/revenue_evolution_point.dart';

class RestaurantReportPdfBuilder {
  const RestaurantReportPdfBuilder();

  Future<Uint8List> build({
    required String establishmentName,
    required String periodLabel,
    required ReportDateRange range,
    required RestaurantReportKpis kpis,
    required List<RevenueEvolutionPoint> revenueEvolution,
    required List<ProductSalesItem> productSales,
  }) async {
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
        build: (_) => [
          _Header(
            establishmentName: establishmentName,
            periodLabel: periodLabel,
            dateLabel:
                '${_formatDate(range.start)} - '
                '${_formatDate(range.end.subtract(const Duration(days: 1)))}',
          ),
          pw.SizedBox(height: 20),
          pw.Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _KpiCard(
                'Chiffre affaires',
                _money(kpis.revenue),
                kpis.revenueChangePercent,
              ),
              _KpiCard(
                'Commandes',
                '${kpis.ordersCount}',
                kpis.ordersChangePercent,
              ),
              _KpiCard(
                'Panier moyen',
                _money(kpis.averageBasket),
                kpis.averageBasketChangePercent,
              ),
              _KpiCard(
                'Clients servis',
                '${kpis.clientsServed}',
                kpis.clientsServedChangePercent,
              ),
            ],
          ),
          pw.SizedBox(height: 24),
          _SectionTitle('Evolution du chiffre affaires'),
          pw.SizedBox(height: 8),
          _RevenueTable(revenueEvolution),
          pw.SizedBox(height: 24),
          _SectionTitle('Ventes par produit'),
          pw.SizedBox(height: 8),
          _ProductSalesTable(productSales),
          pw.SizedBox(height: 16),
          pw.Divider(color: PdfColor.fromHex('#E7E9F1')),
          pw.Text(
            'Rapport genere par Zuri',
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

  static String _formatDate(DateTime date) {
    const months = [
      'janv.',
      'fevr.',
      'mars',
      'avr.',
      'mai',
      'juin',
      'juil.',
      'aout',
      'sept.',
      'oct.',
      'nov.',
      'dec.',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  static String _money(double value) => '${_amount(value)} FC';

  static String _amount(double value) {
    final fixed = value % 1 == 0
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(2);
    final parts = fixed.split('.');
    final whole = parts.first;
    final buffer = StringBuffer();
    for (var index = 0; index < whole.length; index++) {
      final fromEnd = whole.length - index;
      buffer.write(whole[index]);
      if (fromEnd > 1 && fromEnd % 3 == 1) buffer.write(' ');
    }
    if (parts.length > 1) {
      buffer
        ..write(',')
        ..write(parts.last);
    }
    return buffer.toString();
  }

  static String _change(double? value) {
    if (value == null) return 'N/A';
    final sign = value > 0 ? '+' : '';
    return '$sign${value.toStringAsFixed(1)}%';
  }
}

class _Header extends pw.StatelessWidget {
  _Header({
    required this.establishmentName,
    required this.periodLabel,
    required this.dateLabel,
  });

  final String establishmentName;
  final String periodLabel;
  final String dateLabel;

  @override
  pw.Widget build(pw.Context context) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(22),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#1B2744'),
        borderRadius: pw.BorderRadius.circular(14),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            establishmentName,
            style: pw.TextStyle(
              color: PdfColors.white,
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Rapport restaurant',
            style: pw.TextStyle(
              color: PdfColors.white,
              fontSize: 30,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            '$periodLabel - $dateLabel',
            style: pw.TextStyle(
              color: PdfColor.fromHex('#DDE4F6'),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiCard extends pw.StatelessWidget {
  _KpiCard(this.label, this.value, this.change);

  final String label;
  final String value;
  final double? change;

  @override
  pw.Widget build(pw.Context context) {
    return pw.Container(
      width: 246,
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColor.fromHex('#E7E9F1')),
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              color: PdfColor.fromHex('#8A90A5'),
              fontSize: 10,
            ),
          ),
          pw.SizedBox(height: 7),
          pw.Text(
            value,
            style: pw.TextStyle(
              color: PdfColor.fromHex('#1B2744'),
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Variation: ${RestaurantReportPdfBuilder._change(change)}',
            style: pw.TextStyle(
              color: PdfColor.fromHex('#9B1C31'),
              fontSize: 9,
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
    return pw.Text(
      label,
      style: pw.TextStyle(
        color: PdfColor.fromHex('#1B2744'),
        fontSize: 15,
        fontWeight: pw.FontWeight.bold,
      ),
    );
  }
}

class _RevenueTable extends pw.StatelessWidget {
  _RevenueTable(this.points);

  final List<RevenueEvolutionPoint> points;

  @override
  pw.Widget build(pw.Context context) {
    if (points.isEmpty) return pw.Text('Aucune donnee sur la periode.');
    return pw.TableHelper.fromTextArray(
      headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#FFF0F3')),
      headerStyle: pw.TextStyle(
        color: PdfColor.fromHex('#1B2744'),
        fontWeight: pw.FontWeight.bold,
      ),
      cellStyle: pw.TextStyle(color: PdfColor.fromHex('#1B2744'), fontSize: 10),
      headers: const ['Jour', 'CA'],
      data: [
        for (final point in points)
          [
            RestaurantReportPdfBuilder._formatDate(point.day),
            RestaurantReportPdfBuilder._money(point.revenue),
          ],
      ],
    );
  }
}

class _ProductSalesTable extends pw.StatelessWidget {
  _ProductSalesTable(this.items);

  final List<ProductSalesItem> items;

  @override
  pw.Widget build(pw.Context context) {
    if (items.isEmpty) return pw.Text('Aucune vente produit sur la periode.');
    return pw.TableHelper.fromTextArray(
      headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#FFF0F3')),
      headerStyle: pw.TextStyle(
        color: PdfColor.fromHex('#1B2744'),
        fontWeight: pw.FontWeight.bold,
      ),
      cellStyle: pw.TextStyle(color: PdfColor.fromHex('#1B2744'), fontSize: 10),
      headers: const ['#', 'Produit', 'Qte', 'Montant', 'Part'],
      data: [
        for (final item in items)
          [
            '${item.rank}',
            item.label,
            '${item.quantity}',
            RestaurantReportPdfBuilder._money(item.amount),
            '${item.percentage.toStringAsFixed(1)}%',
          ],
      ],
    );
  }
}
