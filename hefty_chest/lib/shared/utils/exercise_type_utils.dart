import 'package:flutter/material.dart';

import '../../gen/common.pbenum.dart';
import '../theme/app_colors.dart';

Color exerciseTypeColor(ExerciseType type) {
  switch (type) {
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

IconData exerciseTypeIcon(ExerciseType type) {
  switch (type) {
    case ExerciseType.EXERCISE_TYPE_WEIGHT_REPS:
      return Icons.fitness_center;
    case ExerciseType.EXERCISE_TYPE_TIME:
      return Icons.timer;
    case ExerciseType.EXERCISE_TYPE_BODYWEIGHT_REPS:
      return Icons.accessibility_new;
    default:
      return Icons.sports;
  }
}

String exerciseTypeName(ExerciseType type) {
  switch (type) {
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
