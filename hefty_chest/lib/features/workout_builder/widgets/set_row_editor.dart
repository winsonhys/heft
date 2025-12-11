import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../core/client.dart';
import '../providers/workout_builder_providers.dart';

/// Editor row for a single set
class SetRowEditor extends ConsumerStatefulWidget {
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
  ConsumerState<SetRowEditor> createState() => _SetRowEditorState();
}

class _SetRowEditorState extends ConsumerState<SetRowEditor> {
  late TextEditingController _weightController;
  late TextEditingController _repsController;
  late TextEditingController _timeController;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(
      text: widget.set.targetWeightKg > 0
          ? widget.set.targetWeightKg.toString()
          : '',
    );
    _repsController = TextEditingController(
      text: widget.set.targetReps > 0 ? widget.set.targetReps.toString() : '',
    );
    _timeController = TextEditingController(
      text: widget.set.targetTimeSeconds > 0
          ? widget.set.targetTimeSeconds.toString()
          : '',
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  void _updateValues({double? weight, int? reps, int? time}) {
    ref.read(workoutBuilderProvider.notifier).updateSetValues(
          widget.sectionId,
          widget.itemId,
          widget.set.id,
          weight: weight,
          reps: reps,
          time: time,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isWeight = widget.exerciseType == ExerciseType.EXERCISE_TYPE_WEIGHT_REPS;
    final isTime = widget.exerciseType == ExerciseType.EXERCISE_TYPE_TIME;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // Set number
          SizedBox(
            width: 32,
            child: Text(
              '${widget.set.setNumber}',
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
                controller: _weightController,
                onChanged: (v) => _updateValues(weight: double.tryParse(v)),
                placeholder: '0',
              ),
            ),
            const SizedBox(width: 8),
            // Reps input
            Expanded(
              child: _InputField(
                controller: _repsController,
                onChanged: (v) => _updateValues(reps: int.tryParse(v)),
                placeholder: '10',
              ),
            ),
          ] else if (isTime) ...[
            // Time input
            Expanded(
              child: _InputField(
                controller: _timeController,
                onChanged: (v) => _updateValues(time: int.tryParse(v)),
                placeholder: '30',
              ),
            ),
          ] else ...[
            // Bodyweight - just reps
            Expanded(
              child: _InputField(
                controller: _repsController,
                onChanged: (v) => _updateValues(reps: int.tryParse(v)),
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
                      widget.sectionId,
                      widget.itemId,
                      widget.set.id,
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
