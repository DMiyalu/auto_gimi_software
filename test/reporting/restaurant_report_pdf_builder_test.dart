import 'package:flutter_test/flutter_test.dart';

import 'package:auto_mobile_software/features/reporting/data/services/restaurant_report_pdf_builder.dart';
import 'package:auto_mobile_software/features/reporting/domain/entities/product_sales_item.dart';
import 'package:auto_mobile_software/features/reporting/domain/entities/report_date_range.dart';
import 'package:auto_mobile_software/features/reporting/domain/entities/restaurant_report_kpis.dart';
import 'package:auto_mobile_software/features/reporting/domain/entities/revenue_evolution_point.dart';

void main() {
  test('build genere un PDF de rapport restaurant partageable', () async {
    final range = ReportDateRange.custom(
      start: DateTime(2026, 8, 10),
      end: DateTime(2026, 8, 15),
    );

    final bytes = await const RestaurantReportPdfBuilder().build(
      establishmentName: 'Restaurant Zolana',
      periodLabel: 'Rapport hebdo semaine en cours',
      range: range,
      kpis: const RestaurantReportKpis(
        revenue: 125000,
        revenueChangePercent: 12.5,
        ordersCount: 18,
        ordersChangePercent: 5,
        averageBasket: 6944.44,
        averageBasketChangePercent: null,
        clientsServed: 9,
        clientsServedChangePercent: 0,
      ),
      revenueEvolution: [
        RevenueEvolutionPoint(day: DateTime(2026, 8, 10), revenue: 50000),
        RevenueEvolutionPoint(day: DateTime(2026, 8, 11), revenue: 75000),
      ],
      productSales: const [
        ProductSalesItem(
          produitId: 'p-1',
          label: 'Poulet mayo',
          quantity: 8,
          amount: 96000,
          percentage: 80,
          rank: 1,
        ),
      ],
    );

    expect(bytes, isNotEmpty);
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
  });
}
