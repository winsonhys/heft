import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/app_colors.dart';
import '../providers/workout_builder_providers.dart';

/// Rest item in a section
class RestItem extends ConsumerStatefulWidget {
  final BuilderItem item;
  final String sectionId;

  const RestItem({
    super.key,
    required this.item,
    required this.sectionId,
  });

  @override
  ConsumerState<RestItem> createState() => _RestItemState();
}

class _RestItemState extends ConsumerState<RestItem> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.item.restDurationSeconds.toString(),
    );
  }

  @override
  void didUpdateWidget(RestItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.restDurationSeconds != widget.item.restDurationSeconds) {
      _controller.text = widget.item.restDurationSeconds.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              controller: _controller,
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
                      widget.sectionId,
                      widget.item.id,
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
                    widget.sectionId,
                    widget.item.id,
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
