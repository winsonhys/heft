import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../shared/theme/app_colors.dart';
import '../providers/workout_builder_providers.dart';

/// Rest item in a section
class RestItem extends HookConsumerWidget {
  final BuilderItem item;
  final String sectionId;

  const RestItem({
    super.key,
    required this.item,
    required this.sectionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController(
      text: item.restDurationSeconds.toString(),
    );

    // Sync controller when item changes (replaces didUpdateWidget)
    useEffect(() {
      controller.text = item.restDurationSeconds.toString();
      return null;
    }, [item.restDurationSeconds]);

    return Padding(
      padding: const EdgeInsets.all(12),
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
          // Duration input
          SizedBox(
            width: 60,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
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
                filled: true,
                fillColor: AppColors.bgPrimary,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                final seconds = int.tryParse(value) ?? 0;
                ref.read(workoutBuilderProvider.notifier).updateRestDuration(
                      sectionId,
                      item.id,
                      seconds,
                    );
              },
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'sec',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textMuted,
            ),
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
              Icons.close,
              size: 18,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
