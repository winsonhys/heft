import 'package:flutter/material.dart';

import '../../../shared/theme/app_colors.dart';

/// Quick stats row showing total workouts, this week, and streak
class QuickStatsRow extends StatelessWidget {
  final int totalWorkouts;
  final int thisWeek;
  final int streak;
  final bool isLoading;

  const QuickStatsRow({
    super.key,
    required this.totalWorkouts,
    required this.thisWeek,
    required this.streak,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              value: totalWorkouts.toString(),
              label: 'Workouts',
              color: AppColors.accentBlue,
              isLoading: isLoading,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              value: thisWeek.toString(),
              label: 'This Week',
              color: AppColors.accentGreen,
              isLoading: isLoading,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              value: streak.toString(),
              label: 'Day Streak',
              color: AppColors.accentOrange,
              isLoading: isLoading,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final bool isLoading;

  const _StatCard({
    required this.value,
    required this.label,
    required this.color,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isLoading)
            Container(
              width: 40,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.bgCardInner,
                borderRadius: BorderRadius.circular(4),
              ),
            )
          else
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
