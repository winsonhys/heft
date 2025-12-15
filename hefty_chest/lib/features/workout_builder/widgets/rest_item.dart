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
    // Helpers for time formatting
    String formatMin(int seconds) =>
        seconds > 0 ? (seconds ~/ 60).toString() : '';
    String formatSec(int seconds) =>
        seconds > 0 ? (seconds % 60).toString().padLeft(2, '0') : '';

    final minController = useTextEditingController(
      text: formatMin(item.restDurationSeconds),
    );
    final secController = useTextEditingController(
      text: formatSec(item.restDurationSeconds),
    );

    // Sync controllers when item changes
    useEffect(() {
      minController.text = formatMin(item.restDurationSeconds);
      secController.text = formatSec(item.restDurationSeconds);
      return null;
    }, [item.restDurationSeconds]);

    void updateDuration() {
      final min = int.tryParse(minController.text) ?? 0;
      final sec = int.tryParse(secController.text) ?? 0;
      ref.read(workoutBuilderProvider.notifier).updateRestDuration(
            sectionId,
            item.id,
            min * 60 + sec,
          );
    }

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
          // Duration inputs
          SizedBox(
            width: 80,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: minController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 8,
                      ),
                      hintText: 'm',
                      hintStyle: TextStyle(color: AppColors.textMuted),
                      filled: true,
                      fillColor: AppColors.bgPrimary,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (_) => updateDuration(),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Text(':', style: TextStyle(color: AppColors.textMuted)),
                ),
                Expanded(
                  child: TextField(
                    controller: secController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 8,
                      ),
                      hintText: 's',
                      hintStyle: TextStyle(color: AppColors.textMuted),
                      filled: true,
                      fillColor: AppColors.bgPrimary,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (_) => updateDuration(),
                  ),
                ),
              ],
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
              Icons.remove_circle_outline, // Changed icon to match set row delete
              size: 18,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
