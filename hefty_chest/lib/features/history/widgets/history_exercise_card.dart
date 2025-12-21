import 'package:flutter/material.dart';

import '../../../core/client.dart';
import '../../../shared/theme/app_colors.dart';
import '../../tracker/models/session_models.dart';
import 'history_set_row.dart';

/// Card displaying an exercise with its completed sets
class HistoryExerciseCard extends StatelessWidget {
  final SessionExerciseModel exercise;

  const HistoryExerciseCard({
    super.key,
    required this.exercise,
  });

  @override
  Widget build(BuildContext context) {
    final isTimeExercise =
        exercise.exerciseType == ExerciseType.EXERCISE_TYPE_TIME ||
            exercise.exerciseType == ExerciseType.EXERCISE_TYPE_CARDIO;

    final completedSets =
        exercise.sets.where((s) => s.isCompleted).length;
    final totalSets = exercise.sets.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    exercise.exerciseName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: completedSets == totalSets
                        ? AppColors.accentGreen.withAlpha(30)
                        : AppColors.bgCardInner,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '$completedSets/$totalSets',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: completedSets == totalSets
                          ? AppColors.accentGreen
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Table header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: AppColors.bgCardInner,
            child: Row(
              children: [
                const SizedBox(
                  width: 32,
                  child: Text(
                    'SET',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    isTimeExercise ? 'TIME' : 'KG',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                if (!isTimeExercise)
                  const Expanded(
                    flex: 2,
                    child: Text(
                      'REPS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                const Expanded(
                  flex: 3,
                  child: Text(
                    'TARGET',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                const SizedBox(width: 24),
              ],
            ),
          ),

          // Sets
          ...exercise.sets.map((set) => HistorySetRow(
                key: ValueKey(set.id.isNotEmpty ? set.id : 'set-${set.setNumber}'),
                set: set,
                exerciseType: exercise.exerciseType,
              )),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
