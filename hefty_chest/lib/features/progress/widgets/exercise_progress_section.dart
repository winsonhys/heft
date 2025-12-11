import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../core/client.dart';
import '../providers/progress_providers.dart';
import 'exercise_selector_modal.dart';

/// Section showing exercise progress chart with exercise selector
class ExerciseProgressSection extends ConsumerWidget {
  const ExerciseProgressSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercisesAsync = ref.watch(exercisesListProvider);
    final selectedId = ref.watch(selectedExerciseIdProvider);
    final progressAsync = selectedId != null
        ? ref.watch(exerciseProgressProvider(selectedId))
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Exercise Progress',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            GestureDetector(
              onTap: () => _showExerciseSelector(context, ref, exercisesAsync),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    exercisesAsync.when(
                      data: (exercises) {
                        final selected = selectedId != null
                            ? exercises
                                .where((e) => e.id == selectedId)
                                .firstOrNull
                            : null;
                        return Text(
                          selected?.name ?? 'Select Exercise',
                          style: TextStyle(
                            fontSize: 13,
                            color: selected != null
                                ? AppColors.textPrimary
                                : AppColors.textMuted,
                          ),
                        );
                      },
                      loading: () => Text(
                        'Loading...',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                      ),
                      error: (_, _) => Text(
                        'Select Exercise',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_drop_down,
                      size: 20,
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildProgressCard(progressAsync),
      ],
    );
  }

  void _showExerciseSelector(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<Exercise>> exercisesAsync,
  ) {
    exercisesAsync.whenData((exercises) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => ExerciseSelectorModal(
          exercises: exercises,
          selectedId: ref.read(selectedExerciseIdProvider),
          onSelect: (exerciseId) {
            ref.read(selectedExerciseIdProvider.notifier).selectExercise(exerciseId);
            Navigator.pop(context);
          },
        ),
      );
    });
  }

  Widget _buildProgressCard(
      AsyncValue<ExerciseProgressSummary?>? progressAsync) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: progressAsync == null
          ? _buildEmptyState()
          : progressAsync.when(
              data: (progress) =>
                  progress != null ? _buildChart(progress) : _buildEmptyState(),
              loading: () => const SizedBox(
                height: 200,
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.accentBlue),
                ),
              ),
              error: (_, _) => _buildEmptyState(),
            ),
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart,
              size: 40,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 8),
            Text(
              'Select an exercise to view progress',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(ExerciseProgressSummary progress) {
    final dataPoints = progress.dataPoints;
    if (dataPoints.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'No progress data yet',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        // Stats row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatItem(
              label: 'Starting',
              value: '${progress.startingWeightKg.toStringAsFixed(1)} kg',
            ),
            _StatItem(
              label: 'Current',
              value: '${progress.currentWeightKg.toStringAsFixed(1)} kg',
            ),
            _StatItem(
              label: 'Best',
              value: '${progress.maxWeightKg.toStringAsFixed(1)} kg',
              isHighlighted: true,
            ),
            _StatItem(
              label: 'Improvement',
              value: '+${progress.improvementPercent.toStringAsFixed(0)}%',
              isHighlighted: progress.improvementPercent > 0,
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Chart
        SizedBox(
          height: 150,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: _getYInterval(dataPoints),
                getDrawingHorizontalLine: (value) => FlLine(
                  color: AppColors.borderColor,
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toInt()}',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 10,
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: dataPoints.asMap().entries.map((entry) {
                    return FlSpot(
                      entry.key.toDouble(),
                      entry.value.bestWeightKg,
                    );
                  }).toList(),
                  isCurved: true,
                  color: AppColors.accentBlue,
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 3,
                        color: AppColors.accentBlue,
                        strokeWidth: 0,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppColors.accentBlue.withValues(alpha: 0.1),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => AppColors.bgPrimary,
                  getTooltipItems: (spots) {
                    return spots.map((spot) {
                      final point = dataPoints[spot.x.toInt()];
                      return LineTooltipItem(
                        '${point.bestWeightKg.toStringAsFixed(1)} kg\n${_formatDate(point.date)}',
                        const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 12,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  double _getYInterval(List<ExerciseProgressPoint> dataPoints) {
    if (dataPoints.isEmpty) return 10;
    final max = dataPoints
        .map((p) => p.bestWeightKg)
        .reduce((a, b) => a > b ? a : b);
    final min = dataPoints
        .map((p) => p.bestWeightKg)
        .reduce((a, b) => a < b ? a : b);
    final range = max - min;
    if (range < 10) return 2;
    if (range < 50) return 10;
    return 20;
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}';
    } catch (_) {
      return dateStr;
    }
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlighted;

  const _StatItem({
    required this.label,
    required this.value,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isHighlighted ? AppColors.accentGreen : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
