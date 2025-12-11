import 'package:flutter/material.dart';

import '../../../shared/theme/app_colors.dart';
import '../providers/program_builder_providers.dart';

/// Card representing a single day in the program
class DayCard extends StatelessWidget {
  final int dayNumber;
  final DayAssignment? assignment;
  final VoidCallback onTap;

  const DayCard({
    super.key,
    required this.dayNumber,
    this.assignment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isWorkout = assignment?.type == DayAssignmentType.workout;
    final isRest = assignment?.type == DayAssignmentType.rest;
    final isEmpty = assignment == null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: (MediaQuery.of(context).size.width - 40 - 6 * 8) / 7,
        height: 80,
        decoration: BoxDecoration(
          color: isWorkout
              ? AppColors.accentBlue.withValues(alpha: 0.15)
              : isRest
                  ? AppColors.accentGreen.withValues(alpha: 0.15)
                  : AppColors.bgCard,
          borderRadius: BorderRadius.circular(8),
          border: isEmpty
              ? Border.all(
                  color: AppColors.borderColor,
                  style: BorderStyle.solid,
                )
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Day number
            Text(
              'Day $dayNumber',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isEmpty ? AppColors.textMuted : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            // Icon or status
            if (isWorkout) ...[
              Icon(
                Icons.fitness_center,
                size: 16,
                color: AppColors.accentBlue,
              ),
              const SizedBox(height: 2),
              Text(
                assignment!.workoutName ?? 'Workout',
                style: const TextStyle(
                  fontSize: 9,
                  color: AppColors.accentBlue,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ] else if (isRest) ...[
              Icon(
                Icons.bedtime,
                size: 16,
                color: AppColors.accentGreen,
              ),
              const SizedBox(height: 2),
              const Text(
                'Rest',
                style: TextStyle(
                  fontSize: 9,
                  color: AppColors.accentGreen,
                ),
              ),
            ] else ...[
              Icon(
                Icons.add,
                size: 16,
                color: AppColors.textMuted,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
