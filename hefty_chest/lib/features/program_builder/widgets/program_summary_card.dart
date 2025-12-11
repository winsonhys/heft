import 'package:flutter/material.dart';

import '../../../shared/theme/app_colors.dart';

/// Card showing program summary statistics
class ProgramSummaryCard extends StatelessWidget {
  final int totalDays;
  final int workoutDays;
  final int restDays;

  const ProgramSummaryCard({
    super.key,
    required this.totalDays,
    required this.workoutDays,
    required this.restDays,
  });

  @override
  Widget build(BuildContext context) {
    final unassigned = totalDays - workoutDays - restDays;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _StatItem(
            label: 'Total Days',
            value: totalDays.toString(),
            color: AppColors.textPrimary,
          ),
          _Divider(),
          _StatItem(
            label: 'Workout',
            value: workoutDays.toString(),
            color: AppColors.accentBlue,
          ),
          _Divider(),
          _StatItem(
            label: 'Rest',
            value: restDays.toString(),
            color: AppColors.accentGreen,
          ),
          _Divider(),
          _StatItem(
            label: 'Unassigned',
            value: unassigned.toString(),
            color: AppColors.textMuted,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
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
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: AppColors.borderColor,
    );
  }
}
