import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/revenue_evolution_point.dart';
import '../providers/restaurant_report_providers.dart';
import '../theme/report_colors.dart';

/// Carte « Évolution du chiffre d'affaires » (barres journalières).
class RevenueEvolutionChart extends ConsumerWidget {
  const RevenueEvolutionChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final evolutionAsync = ref.watch(revenueEvolutionProvider);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
      decoration: BoxDecoration(
        color: ReportColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EAF0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Évolution du chiffre d'affaires",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: ReportColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 220,
            child: evolutionAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Center(
                child: Text(
                  'Impossible de charger le graphique.',
                  style: TextStyle(color: ReportColors.textMuted),
                ),
              ),
              data: (points) => points.isEmpty
                  ? const Center(
                      child: Text(
                        'Aucune donnée sur cette période.',
                        style: TextStyle(color: ReportColors.textMuted),
                      ),
                    )
                  : _RevenueBarChart(points: points),
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 10,
                height: 10,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: ReportColors.accent,
                    borderRadius: BorderRadius.all(Radius.circular(2)),
                  ),
                ),
              ),
              SizedBox(width: 6),
              Text(
                'CA (CDF)',
                style: TextStyle(
                  fontSize: 12,
                  color: ReportColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RevenueBarChart extends StatelessWidget {
  const _RevenueBarChart({required this.points});

  final List<RevenueEvolutionPoint> points;

  static final _dayLabelFormat = DateFormat('E dd/MM', 'fr');

  @override
  Widget build(BuildContext context) {
    final maxRevenue = points.fold<double>(
      0,
      (max, p) => p.revenue > max ? p.revenue : max,
    );
    final maxY = _niceMax(maxRevenue);
    final barWidth = points.length <= 7
        ? 22.0
        : points.length <= 14
        ? 14.0
        : 8.0;
    final labelStep = points.length <= 7
        ? 1
        : points.length <= 14
        ? 2
        : (points.length / 6).ceil().clamp(1, 10);

    return BarChart(
      BarChartData(
        maxY: maxY,
        minY: 0,
        alignment: BarChartAlignment.spaceAround,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 5,
          getDrawingHorizontalLine: (_) => const FlLine(
            color: Color(0xFFE8EAF0),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: maxY / 5,
              getTitlesWidget: (value, meta) {
                if (value < 0 || value > maxY + 0.01) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Text(
                    _formatCompact(value),
                    style: const TextStyle(
                      fontSize: 10,
                      color: ReportColors.textMuted,
                    ),
                    textAlign: TextAlign.right,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (value, meta) {
                final index = value.round();
                if (index < 0 || index >= points.length) {
                  return const SizedBox.shrink();
                }
                if (index % labelStep != 0 && index != points.length - 1) {
                  return const SizedBox.shrink();
                }
                final label = _dayLabelFormat.format(points[index].day);
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 10,
                      color: ReportColors.textMuted,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < points.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: points[i].revenue,
                  width: barWidth,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                  gradient: const LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Color(0xFFEF5350),
                      ReportColors.accent,
                    ],
                  ),
                  label: BarChartRodLabel(
                    show: points.length <= 10 && points[i].revenue > 0,
                    text: _formatCompact(points[i].revenue),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: ReportColors.textPrimary,
                    ),
                    offset: const Offset(0, -2),
                  ),
                ),
              ],
            ),
        ],
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => ReportColors.textPrimary,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final point = points[group.x.toInt()];
              return BarTooltipItem(
                '${_dayLabelFormat.format(point.day)}\n'
                '${_formatCompact(point.revenue)} CDF',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  static double _niceMax(double max) {
    if (max <= 0) return 1000;
    final padded = max * 1.15;
    final exp = (math.log(padded) / math.ln10).floor();
    final magnitude = math.pow(10, exp).toDouble();
    final step = magnitude / 2;
    return (padded / step).ceil() * step;
  }

  static String _formatCompact(double value) {
    if (value >= 1000000) {
      return '${NumberFormat('#0.##', 'fr').format(value / 1000000)}M';
    }
    if (value >= 1000) {
      return '${NumberFormat('#0.##', 'fr').format(value / 1000)}k';
    }
    return NumberFormat('#,##0', 'fr').format(value);
  }
}
