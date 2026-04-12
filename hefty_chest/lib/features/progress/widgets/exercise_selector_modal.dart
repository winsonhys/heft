import 'package:flutter/material.dart';

import '../../../core/client.dart';
import '../../../shared/widgets/exercise_picker_modal.dart';

/// Exercise selector modal for the progress feature.
///
/// Thin wrapper around [ExercisePickerModal] that accepts a pre-loaded
/// exercise list and highlights the currently selected exercise.
class ExerciseSelectorModal extends StatelessWidget {
  final List<Exercise> exercises;
  final String? selectedId;
  final Function(String) onSelect;

  const ExerciseSelectorModal({
    super.key,
    required this.exercises,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return ExercisePickerModal(
      title: 'Select Exercise',
      exercises: exercises,
      selectedId: selectedId,
      onSelect: (exercise) => onSelect(exercise.id),
    );
  }
}
