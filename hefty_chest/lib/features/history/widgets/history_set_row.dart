import 'package:flutter/material.dart';

import '../../../core/client.dart';
import '../../../shared/theme/app_colors.dart';
import '../../tracker/models/session_models.dart';

/// Row displaying a completed set with values and target comparison
class HistorySetRow extends StatelessWidget {
  final SessionSetModel set;
  final ExerciseType exerciseType;

  const HistorySetRow({
    super.key,
    required this.set,
    required this.exerciseType,
  });

  @override
  Widget build(BuildContext context) {
    final isTimeExercise = exerciseType == ExerciseType.EXERCISE_TYPE_TIME ||
        exerciseType == ExerciseType.EXERCISE_TYPE_CARDIO;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: set.isCompleted
            ? AppColors.accentGreen.withAlpha(20)
            : Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderColor.withAlpha(100),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // Set number
          SizedBox(
            width: 32,
            child: Text(
              '${set.setNumber}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),

          // Weight or Time
          Expanded(
            flex: 2,
            child: Text(
              isTimeExercise
                  ? _formatTime(set.timeSeconds)
                  : _formatWeight(set.weightKg),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          // Reps (for weight exercises)
          if (!isTimeExercise)
            Expanded(
              flex: 2,
              child: Text(
                set.reps > 0 ? '${set.reps}' : '-',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

          // Target comparison
          Expanded(
            flex: 3,
            child: _buildTargetComparison(isTimeExercise),
          ),

          // Completed icon
          SizedBox(
            width: 24,
            child: set.isCompleted
                ? const Icon(
                    Icons.check_circle,
                    size: 18,
                    color: AppColors.accentGreen,
                  )
                : const Icon(
                    Icons.radio_button_unchecked,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
          ),
        ],
      ),
    );
  }

  String _formatWeight(double weight) {
    if (weight <= 0) return '-';
    if (weight == weight.roundToDouble()) {
      return '${weight.round()} kg';
    }
    return '${weight.toStringAsFixed(1)} kg';
  }

  String _formatTime(int seconds) {
    if (seconds <= 0) return '-';
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    if (mins > 0) {
      return '$mins:${secs.toString().padLeft(2, '0')}';
    }
    return '${secs}s';
  }

  Widget _buildTargetComparison(bool isTimeExercise) {
    final hasTarget = isTimeExercise
        ? set.targetTimeSeconds > 0
        : set.targetWeightKg > 0 || set.targetReps > 0;

    if (!hasTarget) {
      return const Text(
        '-',
        style: TextStyle(
          fontSize: 12,
          color: AppColors.textMuted,
        ),
      );
    }

    if (isTimeExercise) {
      final targetStr = _formatTime(set.targetTimeSeconds);
      final metTarget = set.timeSeconds >= set.targetTimeSeconds;
      return Row(
        children: [
          Icon(
            metTarget ? Icons.check : Icons.arrow_upward,
            size: 12,
            color: metTarget ? AppColors.accentGreen : AppColors.accentOrange,
          ),
          const SizedBox(width: 4),
          Text(
            targetStr,
            style: TextStyle(
              fontSize: 12,
              color: metTarget ? AppColors.accentGreen : AppColors.accentOrange,
            ),
          ),
        ],
      );
    }

    // Weight/reps target
    final weightStr = set.targetWeightKg > 0
        ? '${set.targetWeightKg.round()}'
        : '-';
    final repsStr = set.targetReps > 0 ? '${set.targetReps}' : '-';
    final targetStr = '$weightStr×$repsStr';

    final metWeight = set.weightKg >= set.targetWeightKg;
    final metReps = set.reps >= set.targetReps;
    final metTarget = metWeight && metReps;

    return Row(
      children: [
        Icon(
          metTarget ? Icons.check : Icons.arrow_upward,
          size: 12,
          color: metTarget ? AppColors.accentGreen : AppColors.accentOrange,
        ),
        const SizedBox(width: 4),
        Text(
          targetStr,
          style: TextStyle(
            fontSize: 12,
            color: metTarget ? AppColors.accentGreen : AppColors.accentOrange,
          ),
        ),
      ],
    );
  }
}
