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

    final restMinController = useTextEditingController(
      text: formatMin(set.restDurationSeconds ?? 0),
    );
    final restSecController = useTextEditingController(
      text: formatSec(set.restDurationSeconds ?? 0),
    );

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

    void onRestChanged() {
      final min = int.tryParse(restMinController.text) ?? 0;
      final sec = int.tryParse(restSecController.text) ?? 0;
      updateValues(rest: min * 60 + sec);
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
              ),
            ),
            const SizedBox(width: 8),
            // Reps input
            Expanded(
              child: _InputField(
                controller: repsController,
                onChanged: (v) => updateValues(reps: int.tryParse(v)),
                placeholder: 'reps',
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
              ),
            ),
          ],
          
          const SizedBox(width: 8),
          
          // Rest Timer Input
          SizedBox(
            width: 80,
            child: Row(
              children: [
                const Icon(Icons.timer_outlined, size: 16, color: AppColors.textMuted),
                const SizedBox(width: 4),
                 Expanded(
                  child: _InputField(
                    controller: restMinController,
                    onChanged: (_) => onRestChanged(),
                    placeholder: 'm',
                    textSize: 12,
                  ),
                ),
                Text(':', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                Expanded(
                  child: _InputField(
                    controller: restSecController,
                    onChanged: (_) => onRestChanged(),
                    placeholder: 's',
                    textSize: 12,
                  ),
                ),
              ],
            ),
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

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final String placeholder;
  final double textSize;

  const _InputField({
    required this.controller,
    required this.onChanged,
    required this.placeholder,
    this.textSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: textSize,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 8,
        ),
        hintText: placeholder,
        hintStyle: TextStyle(color: AppColors.textMuted, fontSize: textSize),
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
