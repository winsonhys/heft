import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../core/client.dart';

/// Bar chart showing weekly workout activity
class WeeklyActivityChart extends StatelessWidget {
  final List<WeeklyActivityDay> weeklyData;
  final bool isLoading;

  const WeeklyActivityChart({
    super.key,
    required this.weeklyData,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.accentBlue,
              ),
            )
          : weeklyData.isEmpty
              ? Center(
                  child: Text(
                    'No activity data',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 14,
                    ),
                  ),
                )
              : BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: _getMaxY(),
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (_) => AppColors.bgPrimary,
                        tooltipPadding: const EdgeInsets.all(8),
                        tooltipMargin: 8,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final day = weeklyData[group.x.toInt()];
                          return BarTooltipItem(
                            '${day.workoutCount} workout${day.workoutCount != 1 ? 's' : ''}',
                            const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= weeklyData.length) {
                              return const SizedBox.shrink();
                            }
                            final day = weeklyData[value.toInt()];
                            final label = _getDayLabel(day.dayOfWeek);
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                label,
                                style: TextStyle(
                                  color: day.isToday
                                      ? AppColors.accentBlue
                                      : AppColors.textMuted,
                                  fontSize: 12,
                                  fontWeight: day.isToday
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: _buildBarGroups(),
                  ),
                ),
    );
  }

  double _getMaxY() {
    if (weeklyData.isEmpty) return 3;
    final max = weeklyData
        .map((d) => d.workoutCount)
        .reduce((a, b) => a > b ? a : b);
    return (max + 1).toDouble();
  }

  String _getDayLabel(String dayOfWeek) {
    switch (dayOfWeek.toLowerCase()) {
      case 'monday':
        return 'M';
      case 'tuesday':
        return 'T';
      case 'wednesday':
        return 'W';
      case 'thursday':
        return 'T';
      case 'friday':
        return 'F';
      case 'saturday':
        return 'S';
      case 'sunday':
        return 'S';
      default:
        return dayOfWeek.isNotEmpty ? dayOfWeek[0] : '';
    }
  }

  List<BarChartGroupData> _buildBarGroups() {
    return weeklyData.asMap().entries.map((entry) {
      final index = entry.key;
      final day = entry.value;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: day.workoutCount.toDouble(),
            color: day.isToday ? AppColors.accentBlue : AppColors.accentBlue.withValues(alpha: 0.6),
            width: 28,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ],
      );
    }).toList();
  }
}
