import 'package:flutter/material.dart';

import '../../../shared/theme/app_colors.dart';
import '../providers/program_builder_providers.dart';
import 'weekday_chip_row.dart';

/// One workout entry in the program builder, showing the name plus the
/// weekday chips it runs on. Tapping the row opens the schedule modal.
class WorkoutRow extends StatelessWidget {
  final int index;
  final ProgramWorkoutDraft draft;
  final VoidCallback onTap;

  const WorkoutRow({
    super.key,
    required this.index,
    required this.draft,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: Key('workout_row_$index'),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accentBlue.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.fitness_center,
                      size: 18, color: AppColors.accentBlue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    draft.workoutName.isEmpty ? 'Workout' : draft.workoutName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textMuted),
              ],
            ),
            const SizedBox(height: 12),
            WeekdayChipRow(selected: draft.days, readOnly: true),
          ],
        ),
      ),
    );
  }
}
