import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../core/client.dart';
import '../providers/workout_builder_providers.dart';
import 'set_row_editor.dart';

/// Exercise item in a section
class ExerciseItem extends ConsumerWidget {
  final BuilderItem item;
  final String sectionId;

  const ExerciseItem({
    super.key,
    required this.item,
    required this.sectionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWeight = item.exerciseType == ExerciseType.EXERCISE_TYPE_WEIGHT_REPS;
    final isTime = item.exerciseType == ExerciseType.EXERCISE_TYPE_TIME;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              // Exercise name
              Expanded(
                child: Text(
                  item.exerciseName ?? 'Exercise',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              // Exercise type badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getTypeColor().withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getTypeName(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: _getTypeColor(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Delete button
              GestureDetector(
                onTap: () {
                  ref
                      .read(workoutBuilderProvider.notifier)
                      .deleteExercise(sectionId, item.id);
                },
                child: Icon(
                  Icons.close,
                  size: 18,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Sets header
          Row(
            children: [
              const SizedBox(width: 32),
              if (isWeight) ...[
                const Expanded(
                  child: Text(
                    'Weight (kg)',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Expanded(
                  child: Text(
                    'Reps',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                    textAlign: TextAlign.center,
                  ),
                ),
              ] else if (isTime) ...[
                const Expanded(
                  child: Text(
                    'Time (sec)',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                    textAlign: TextAlign.center,
                  ),
                ),
              ] else ...[
                const Expanded(
                  child: Text(
                    'Reps',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              const SizedBox(width: 32),
            ],
          ),
          const SizedBox(height: 8),
          // Sets
          ...item.sets.map((set) => SetRowEditor(
                set: set,
                sectionId: sectionId,
                itemId: item.id,
                exerciseType: item.exerciseType,
              )),
          // Add set button
          GestureDetector(
            onTap: () {
              ref.read(workoutBuilderProvider.notifier).addSet(sectionId, item.id);
            },
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, size: 16, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    'Add Set',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor() {
    switch (item.exerciseType) {
      case ExerciseType.EXERCISE_TYPE_WEIGHT_REPS:
        return AppColors.accentBlue;
      case ExerciseType.EXERCISE_TYPE_TIME:
        return AppColors.accentOrange;
      case ExerciseType.EXERCISE_TYPE_BODYWEIGHT_REPS:
        return AppColors.accentGreen;
      default:
        return AppColors.textMuted;
    }
  }

  String _getTypeName() {
    switch (item.exerciseType) {
      case ExerciseType.EXERCISE_TYPE_WEIGHT_REPS:
        return 'Weight';
      case ExerciseType.EXERCISE_TYPE_TIME:
        return 'Time';
      case ExerciseType.EXERCISE_TYPE_BODYWEIGHT_REPS:
        return 'Bodyweight';
      default:
        return 'Other';
    }
  }
}
