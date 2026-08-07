/// Plage de dates utilisée par l'écran Rapports (restaurant).
///
/// [start] est inclusif, [end] est exclusif — convention habituelle pour
/// les agrégations journalières (`[aujourd'hui 00:00, demain 00:00)`).
class ReportDateRange {
  ReportDateRange({
    required this.start,
    required this.end,
    required this.preset,
  }) : assert(!end.isBefore(start));

  final DateTime start;
  final DateTime end;
  final ReportPeriodPreset preset;

  Duration get duration => end.difference(start);

  /// Période immédiatement précédente, de même durée (ex. « vs hier »).
  ReportDateRange get previous {
    final d = duration;
    return ReportDateRange(
      start: start.subtract(d),
      end: start,
      preset: ReportPeriodPreset.custom,
    );
  }

  bool contains(DateTime instant) {
    return !instant.isBefore(start) && instant.isBefore(end);
  }

  factory ReportDateRange.today([DateTime? now]) {
    final n = now ?? DateTime.now();
    final dayStart = DateTime(n.year, n.month, n.day);
    return ReportDateRange(
      start: dayStart,
      end: dayStart.add(const Duration(days: 1)),
      preset: ReportPeriodPreset.today,
    );
  }

  factory ReportDateRange.yesterday([DateTime? now]) {
    final today = ReportDateRange.today(now);
    return ReportDateRange(
      start: today.start.subtract(const Duration(days: 1)),
      end: today.start,
      preset: ReportPeriodPreset.yesterday,
    );
  }

  factory ReportDateRange.last7Days([DateTime? now]) {
    final today = ReportDateRange.today(now);
    return ReportDateRange(
      start: today.start.subtract(const Duration(days: 6)),
      end: today.end,
      preset: ReportPeriodPreset.last7Days,
    );
  }

  factory ReportDateRange.last30Days([DateTime? now]) {
    final today = ReportDateRange.today(now);
    return ReportDateRange(
      start: today.start.subtract(const Duration(days: 29)),
      end: today.end,
      preset: ReportPeriodPreset.last30Days,
    );
  }

  factory ReportDateRange.custom({
    required DateTime start,
    required DateTime end,
  }) {
    final normalizedStart = DateTime(start.year, start.month, start.day);
    final normalizedEnd = DateTime(end.year, end.month, end.day);
    final exclusiveEnd = normalizedEnd.isAtSameMomentAs(normalizedStart)
        ? normalizedStart.add(const Duration(days: 1))
        : normalizedEnd.add(const Duration(days: 1));
    return ReportDateRange(
      start: normalizedStart,
      end: exclusiveEnd,
      preset: ReportPeriodPreset.custom,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ReportDateRange &&
        other.start == start &&
        other.end == end &&
        other.preset == preset;
  }

  @override
  int get hashCode => Object.hash(start, end, preset);
}

enum ReportPeriodPreset {
  today,
  yesterday,
  last7Days,
  last30Days,
  custom,
}
