import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../shared/theme/app_colors.dart';
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
    final timeController = useTextEditingController(
      text: set.targetTimeSeconds > 0 ? set.targetTimeSeconds.toString() : '',
    );

    void updateValues({double? weight, int? reps, int? time}) {
      ref.read(workoutBuilderProvider.notifier).updateSetValues(
            sectionId,
            itemId,
            set.id,
            weight: weight,
            reps: reps,
            time: time,
          );
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
                placeholder: '0',
              ),
            ),
            const SizedBox(width: 8),
            // Reps input
            Expanded(
              child: _InputField(
                controller: repsController,
                onChanged: (v) => updateValues(reps: int.tryParse(v)),
                placeholder: '10',
              ),
            ),
          ] else if (isTime) ...[
            // Time input
            Expanded(
              child: _InputField(
                controller: timeController,
                onChanged: (v) => updateValues(time: int.tryParse(v)),
                placeholder: '30',
              ),
            ),
          ] else ...[
            // Bodyweight - just reps
            Expanded(
              child: _InputField(
                controller: repsController,
                onChanged: (v) => updateValues(reps: int.tryParse(v)),
                placeholder: '10',
              ),
            ),
          ],
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

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final String placeholder;

  const _InputField({
    required this.controller,
    required this.onChanged,
    required this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 14,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 8,
        ),
        hintText: placeholder,
        hintStyle: TextStyle(color: AppColors.textMuted),
        filled: true,
        fillColor: AppColors.bgPrimary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: onChanged,
    );
  }
}
