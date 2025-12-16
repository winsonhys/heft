import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/duration_picker.dart';
import '../providers/workout_builder_providers.dart';

/// Rest item in a section
class RestItem extends ConsumerWidget {
  final BuilderItem item;
  final String sectionId;

  const RestItem({
    super.key,
    required this.item,
    required this.sectionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, right: 12, bottom: 12),
      child: Row(
        children: [
          // Rest icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.accentGreen.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.timer,
              size: 18,
              color: AppColors.accentGreen,
            ),
          ),
          const SizedBox(width: 12),
          // Label
          const Text(
            'Rest',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 12),
          // Duration picker
          DurationPickerTrigger(
            duration: Duration(seconds: item.restDurationSeconds),
            onChanged: (duration) {
              ref.read(workoutBuilderProvider.notifier).updateRestDuration(
                    sectionId,
                    item.id,
                    duration.inSeconds,
                  );
            },
          ),
          const Spacer(),
          // Delete button
          GestureDetector(
            onTap: () {
              ref.read(workoutBuilderProvider.notifier).deleteExercise(
                    sectionId,
                    item.id,
                  );
            },
            child: Icon(
              Icons.remove_circle_outline,
              size: 18,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
