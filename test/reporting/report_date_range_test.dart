import 'package:flutter_test/flutter_test.dart';

import 'package:auto_mobile_software/features/reporting/domain/entities/report_date_range.dart';

void main() {
  final fixedNow = DateTime(2026, 6, 6, 15, 30);

  group('ReportDateRange presets', () {
    test('today couvre [minuit, demain)', () {
      final range = ReportDateRange.today(fixedNow);

      expect(range.preset, ReportPeriodPreset.today);
      expect(range.start, DateTime(2026, 6, 6));
      expect(range.end, DateTime(2026, 6, 7));
      expect(range.contains(DateTime(2026, 6, 6, 23, 59)), isTrue);
      expect(range.contains(DateTime(2026, 6, 7)), isFalse);
    });

    test('yesterday est la veille de today', () {
      final range = ReportDateRange.yesterday(fixedNow);

      expect(range.preset, ReportPeriodPreset.yesterday);
      expect(range.start, DateTime(2026, 6, 5));
      expect(range.end, DateTime(2026, 6, 6));
    });

    test('last7Days inclut aujourd’hui et les 6 jours précédents', () {
      final range = ReportDateRange.last7Days(fixedNow);

      expect(range.preset, ReportPeriodPreset.last7Days);
      expect(range.start, DateTime(2026, 5, 31));
      expect(range.end, DateTime(2026, 6, 7));
      expect(range.duration.inDays, 7);
    });

    test('last30Days couvre 30 jours calendaires', () {
      final range = ReportDateRange.last30Days(fixedNow);

      expect(range.preset, ReportPeriodPreset.last30Days);
      expect(range.duration.inDays, 30);
      expect(range.end, DateTime(2026, 6, 7));
    });

    test('custom normalise et rend end exclusif', () {
      final range = ReportDateRange.custom(
        start: DateTime(2026, 6, 1, 10),
        end: DateTime(2026, 6, 3, 18),
      );

      expect(range.preset, ReportPeriodPreset.custom);
      expect(range.start, DateTime(2026, 6, 1));
      expect(range.end, DateTime(2026, 6, 4));
    });

    test('custom sur un seul jour produit une journée exclusive', () {
      final range = ReportDateRange.custom(
        start: DateTime(2026, 6, 6),
        end: DateTime(2026, 6, 6),
      );

      expect(range.start, DateTime(2026, 6, 6));
      expect(range.end, DateTime(2026, 6, 7));
    });
  });

  group('ReportDateRange.previous', () {
    test('renvoie la période immédiatement précédente de même durée', () {
      final today = ReportDateRange.today(fixedNow);
      final previous = today.previous;

      expect(previous.start, DateTime(2026, 6, 5));
      expect(previous.end, DateTime(2026, 6, 6));
      expect(previous.duration, today.duration);
    });
  });
}
