import 'package:flutter/material.dart';

import '../../../shared/theme/app_colors.dart';

/// Stats grid showing days active, workouts, and volume
class StatsGrid extends StatelessWidget {
  final int daysActive;
  final int totalWorkouts;
  final int totalVolumeKg;
  final bool isLoading;

  const StatsGrid({
    super.key,
    required this.daysActive,
    required this.totalWorkouts,
    required this.totalVolumeKg,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatItem(
            value: daysActive.toString(),
            label: 'DAYS ACTIVE',
            isLoading: isLoading,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatItem(
            value: totalWorkouts.toString(),
            label: 'WORKOUTS',
            isLoading: isLoading,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatItem(
            value: _formatVolume(totalVolumeKg),
            label: 'KG LIFTED',
            isLoading: isLoading,
          ),
        ),
      ],
    );
  }

  String _formatVolume(int kg) {
    if (kg >= 1000) {
      return '${(kg / 1000).toStringAsFixed(1)}k';
    }
    return kg.toString();
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final bool isLoading;

  const _StatItem({
    required this.value,
    required this.label,
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
        children: [
          if (isLoading)
            Container(
              width: 40,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.bgCardInner,
                borderRadius: BorderRadius.circular(4),
              ),
            )
          else
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
