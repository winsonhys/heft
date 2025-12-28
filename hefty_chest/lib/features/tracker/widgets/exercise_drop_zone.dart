import 'package:flutter/material.dart';

import '../../../shared/theme/app_colors.dart';
import 'draggable_exercise_card.dart';

/// A drop zone that appears between exercises or at section edges
class ExerciseDropZone extends StatefulWidget {
  final String sectionName;
  final int targetIndex;
  final void Function(TrackerDragData dragData) onAccept;
  final bool isDragging;

  const ExerciseDropZone({
    super.key,
    required this.sectionName,
    required this.targetIndex,
    required this.onAccept,
    this.isDragging = false,
  });

  @override
  State<ExerciseDropZone> createState() => _ExerciseDropZoneState();
}

class _ExerciseDropZoneState extends State<ExerciseDropZone> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    // Only show expanded drop zone when actively dragging
    if (!widget.isDragging) {
      return const SizedBox(height: 0);
    }

    return DragTarget<TrackerDragData>(
      onWillAcceptWithDetails: (details) {
        // Don't accept drops at the same position
        final data = details.data;
        if (data.fromSectionName == widget.sectionName) {
          // Same section - check if it's the same position or adjacent
          if (data.fromIndex == widget.targetIndex ||
              data.fromIndex == widget.targetIndex - 1) {
            return false;
          }
        }
        setState(() => _isHovering = true);
        return true;
      },
      onLeave: (_) {
        setState(() => _isHovering = false);
      },
      onAcceptWithDetails: (details) {
        setState(() => _isHovering = false);
        widget.onAccept(details.data);
      },
      builder: (context, candidateData, rejectedData) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: _isHovering ? 56 : 24,
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: _isHovering
                ? AppColors.accentBlue.withValues(alpha: 0.2)
                : AppColors.accentBlue.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isHovering
                  ? AppColors.accentBlue
                  : AppColors.accentBlue.withValues(alpha: 0.3),
              width: _isHovering ? 2 : 1,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
          ),
          child: Center(
            child: _isHovering
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        size: 18,
                        color: AppColors.accentBlue,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Drop here',
                        style: TextStyle(
                          color: AppColors.accentBlue,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                : Icon(
                    Icons.more_horiz,
                    size: 16,
                    color: AppColors.accentBlue.withValues(alpha: 0.5),
                  ),
          ),
        );
      },
    );
  }
}

/// Drop zone for creating a new section when dragging
class NewSectionDropZone extends StatefulWidget {
  final void Function(TrackerDragData dragData) onAccept;
  final bool isDragging;

  const NewSectionDropZone({
    super.key,
    required this.onAccept,
    this.isDragging = false,
  });

  @override
  State<NewSectionDropZone> createState() => _NewSectionDropZoneState();
}

class _NewSectionDropZoneState extends State<NewSectionDropZone> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.isDragging) {
      return const SizedBox.shrink();
    }

    return DragTarget<TrackerDragData>(
      onWillAcceptWithDetails: (details) {
        setState(() => _isHovering = true);
        return true;
      },
      onLeave: (_) {
        setState(() => _isHovering = false);
      },
      onAcceptWithDetails: (details) {
        setState(() => _isHovering = false);
        widget.onAccept(details.data);
      },
      builder: (context, candidateData, rejectedData) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: _isHovering ? 80 : 56,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _isHovering
                ? AppColors.accentPurple.withValues(alpha: 0.2)
                : AppColors.accentPurple.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isHovering
                  ? AppColors.accentPurple
                  : AppColors.accentPurple.withValues(alpha: 0.3),
              width: _isHovering ? 2 : 1,
            ),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isHovering ? Icons.create_new_folder : Icons.create_new_folder_outlined,
                  size: 20,
                  color: AppColors.accentPurple,
                ),
                const SizedBox(width: 8),
                Text(
                  _isHovering ? 'Create new section' : 'Drop to create section',
                  style: TextStyle(
                    color: AppColors.accentPurple,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
