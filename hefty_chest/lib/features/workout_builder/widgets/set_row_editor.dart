import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
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

    // Sync controllers when set values change externally (e.g., linked sets)
    useEffect(() {
      final newWeight = set.targetWeightKg > 0 ? set.targetWeightKg.toString() : '';
      if (weightController.text != newWeight) {
        weightController.text = newWeight;
      }
      return null;
    }, [set.targetWeightKg]);

    useEffect(() {
      final newReps = set.targetReps > 0 ? set.targetReps.toString() : '';
      if (repsController.text != newReps) {
        repsController.text = newReps;
      }
      return null;
    }, [set.targetReps]);

    useEffect(() {
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
              child: _InputField(
                controller: weightController,
                onChanged: (v) => updateValues(weight: double.tryParse(v)),
                placeholder: 'kg',
                isEdited: set.isEdited,
              ),
            ),
            const SizedBox(width: 8),
            // Reps input
            Expanded(
              child: _InputField(
                controller: repsController,
                onChanged: (v) => updateValues(reps: int.tryParse(v)),
                placeholder: 'reps',
                isEdited: set.isEdited,
              ),
            ),
          ] else if (isTime) ...[
            // Time input (Min : Sec)
            Expanded(
              child: Row(
                children: [
                   Expanded(
                    child: _InputField(
                      controller: timeMinController,
                      onChanged: (_) => onTimeChanged(),
                      placeholder: 'm',
                      isEdited: set.isEdited,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Text(':', style: TextStyle(color: AppColors.textMuted)),
                  ),
                  Expanded(
                    child: _InputField(
                      controller: timeSecController,
                      onChanged: (_) => onTimeChanged(),
                      placeholder: 's',
                      isEdited: set.isEdited,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Bodyweight - just reps
            Expanded(
              child: _InputField(
                controller: repsController,
                onChanged: (v) => updateValues(reps: int.tryParse(v)),
                placeholder: 'reps',
                isEdited: set.isEdited,
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

class _InputField extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final String placeholder;
  final bool isEdited;

  const _InputField({
    required this.controller,
    required this.onChanged,
    required this.placeholder,
    this.isEdited = true,
  });

  @override
  State<_InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<_InputField> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      // Select all text when focused
      widget.controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: widget.controller.text.length,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      focusNode: _focusNode,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 14,
        // Show muted color for unedited (linked) values
        color: widget.isEdited ? AppColors.textPrimary : AppColors.textMuted,
      ),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 8,
        ),
        hintText: widget.placeholder,
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
        filled: true,
        fillColor: AppColors.bgPrimary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: widget.onChanged,
    );
  }
}
