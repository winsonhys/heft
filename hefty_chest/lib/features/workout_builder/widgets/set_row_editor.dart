import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/duration_picker.dart';
import '../../../core/client.dart';
import '../providers/workout_builder_providers.dart';

/// Editor row for a single set
class SetRowEditor extends HookConsumerWidget {
  final BuilderSet set;
  final String sectionId;
  final String itemId;
  final ExerciseType exerciseType;

  const SetRowEditor({
    super.key,
    required this.set,
    required this.sectionId,
    required this.itemId,
    required this.exerciseType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weightController = useTextEditingController(
      text: set.targetWeightKg > 0 ? set.targetWeightKg.toString() : '',
    );
    final repsController = useTextEditingController(
      text: set.targetReps > 0 ? set.targetReps.toString() : '',
    );

    // Helpers for time formatting
    String formatMin(int seconds) =>
        seconds > 0 ? (seconds ~/ 60).toString() : '';
    String formatSec(int seconds) =>
        seconds > 0 ? (seconds % 60).toString().padLeft(2, '0') : '';

    final timeMinController = useTextEditingController(
      text: formatMin(set.targetTimeSeconds),
    );
    final timeSecController = useTextEditingController(
      text: formatSec(set.targetTimeSeconds),
    );

    // FocusNodes to detect when user is actively typing (skip sync for focused field)
    final weightFocus = useFocusNode();
    final repsFocus = useFocusNode();
    final timeMinFocus = useFocusNode();
    final timeSecFocus = useFocusNode();

    // Sync controllers when set values change externally (e.g., linked sets)
    // Skip sync when field has focus to avoid overwriting user's typing
    useEffect(() {
      if (weightFocus.hasFocus) return null;
      final newWeight = set.targetWeightKg > 0 ? set.targetWeightKg.toString() : '';
      if (weightController.text != newWeight) {
        weightController.text = newWeight;
      }
      return null;
    }, [set.targetWeightKg]);

    useEffect(() {
      if (repsFocus.hasFocus) return null;
      final newReps = set.targetReps > 0 ? set.targetReps.toString() : '';
      if (repsController.text != newReps) {
        repsController.text = newReps;
      }
      return null;
    }, [set.targetReps]);

    useEffect(() {
      if (timeMinFocus.hasFocus || timeSecFocus.hasFocus) return null;
      final newMin = formatMin(set.targetTimeSeconds);
      final newSec = formatSec(set.targetTimeSeconds);
      if (timeMinController.text != newMin) {
        timeMinController.text = newMin;
      }
      if (timeSecController.text != newSec) {
        timeSecController.text = newSec;
      }
      return null;
    }, [set.targetTimeSeconds]);

    void updateValues({double? weight, int? reps, int? time, int? rest}) {
      ref.read(workoutBuilderProvider.notifier).updateSetValues(
            sectionId,
            itemId,
            set.id,
            weight: weight,
            reps: reps,
            time: time,
            rest: rest,
          );
    }

    void onTimeChanged() {
      final min = int.tryParse(timeMinController.text) ?? 0;
      final sec = int.tryParse(timeSecController.text) ?? 0;
      updateValues(time: min * 60 + sec);
    }

    final isWeight = exerciseType == ExerciseType.EXERCISE_TYPE_WEIGHT_REPS;
    final isTime = exerciseType == ExerciseType.EXERCISE_TYPE_TIME;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // Set number
          SizedBox(
            width: 32,
            child: Text(
              '${set.setNumber}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Weight input (for weight exercises)
          if (isWeight) ...[
            Expanded(
              child: FTextField(
                focusNode: weightFocus,
                control: .managed(controller: weightController, onChange: (v) => updateValues(weight: double.tryParse(v.text))), hint: 'kg',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
            const SizedBox(width: 8),
            // Reps input
            Expanded(
              child: FTextField(
                focusNode: repsFocus,
                control: .managed(controller: repsController, onChange: (v) => updateValues(reps: int.tryParse(v.text))), hint: 'reps',
                keyboardType: TextInputType.number,
              ),
            ),
          ] else if (isTime) ...[
            // Time input (Min : Sec)
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: FTextField(
                      focusNode: timeMinFocus,
                      control: .managed(controller: timeMinController, onChange: (_) => onTimeChanged()), hint: 'm',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Text(':', style: TextStyle(color: AppColors.textMuted)),
                  ),
                  Expanded(
                    child: FTextField(
                      focusNode: timeSecFocus,
                      control: .managed(controller: timeSecController, onChange: (_) => onTimeChanged()), hint: 's',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Bodyweight - just reps
            Expanded(
              child: FTextField(
                focusNode: repsFocus,
                control: .managed(controller: repsController, onChange: (v) => updateValues(reps: int.tryParse(v.text))), hint: 'reps',
                keyboardType: TextInputType.number,
              ),
            ),
          ],
          
          const SizedBox(width: 8),

          // Rest Timer Picker
          DurationPickerTrigger(
            duration: Duration(seconds: set.restDurationSeconds ?? 0),
            onChanged: (duration) => updateValues(rest: duration.inSeconds),
            isEdited: set.isEdited,
          ),

          // Delete set button
          SizedBox(
            width: 32,
            child: GestureDetector(
              onTap: () {
                ref.read(workoutBuilderProvider.notifier).deleteSet(
                      sectionId,
                      itemId,
                      set.id,
                    );
              },
              child: Icon(
                Icons.remove_circle_outline,
                size: 18,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
