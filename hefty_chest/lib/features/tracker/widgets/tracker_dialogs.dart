import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../workout_builder/widgets/exercise_search_modal.dart';
import '../models/session_models.dart';
import '../providers/session_providers.dart';

/// Shows a dialog to get a section name, then returns it.
Future<String?> showSectionNameDialog(BuildContext context, {String confirmLabel = 'Create'}) async {
  final sectionNameController = TextEditingController();
  return showFDialog<String>(
    context: context,
    builder: (context, style, animation) {
      return FDialog(
        style: style, // ignore: implicit_call_tearoffs
        animation: animation,
        title: const Text('New Section'),
        body: FTextField(
          control: .managed(controller: sectionNameController),
          hint: 'Section name',
          autofocus: true,
        ),
        actions: [
          FButton(
            style: FButtonStyle.ghost(),
            onPress: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FButton(
            onPress: () => Navigator.pop(context, sectionNameController.text.trim()),
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
}

/// Shows the add-section flow: section name dialog → exercise picker.
Future<void> showAddSectionFlow(BuildContext context, WidgetRef ref) async {
  final sectionName = await showSectionNameDialog(context, confirmLabel: 'Next');
  if (sectionName == null || sectionName.isEmpty || !context.mounted) return;

  showAddExerciseModal(context, ref, sectionName);
}

/// Shows the new-section dialog for drag-drop, then creates section with exercise.
Future<void> showNewSectionDialog(BuildContext context, WidgetRef ref, String exerciseId) async {
  final sectionName = await showSectionNameDialog(context);
  if (sectionName == null || sectionName.isEmpty) return;

  ref.read(activeSessionProvider.notifier).createNewSectionWithExercise(
    exerciseId: exerciseId,
    sectionName: sectionName,
  );
}

/// Shows the exercise search modal for adding exercises to a section.
void showAddExerciseModal(BuildContext context, WidgetRef ref, String sectionName) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.bgCard,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => ExerciseSearchModal(
      onSelect: (exercise) {
        ref.read(activeSessionProvider.notifier).addExercise(
          exerciseId: exercise.id,
          exerciseName: exercise.name,
          exerciseType: exercise.exerciseType,
          sectionName: sectionName,
        );
        Navigator.pop(context);
      },
    ),
  );
}

/// Confirms exercise deletion with a dialog.
Future<void> confirmDeleteExercise(BuildContext context, WidgetRef ref, SessionExerciseModel exercise) async {
  final confirm = await showConfirmDialog(
    context: context,
    title: 'Delete Exercise?',
    message: 'Are you sure you want to delete "${exercise.exerciseName}"?',
    confirmLabel: 'Delete',
    isDestructive: true,
  );

  if (confirm) {
    ref.read(activeSessionProvider.notifier).deleteExercise(sessionExerciseId: exercise.id);
  }
}

/// Confirms section deletion with a dialog.
Future<void> confirmDeleteSection(BuildContext context, WidgetRef ref, String sectionName) async {
  final confirm = await showConfirmDialog(
    context: context,
    title: 'Delete Section?',
    message: 'Are you sure you want to delete the "$sectionName" section and all its exercises?',
    confirmLabel: 'Delete',
    isDestructive: true,
  );

  if (confirm) {
    ref.read(activeSessionProvider.notifier).deleteSection(sectionName: sectionName);
  }
}
