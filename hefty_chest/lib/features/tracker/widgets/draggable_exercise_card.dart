import 'package:flutter/material.dart';

import '../../../shared/theme/app_colors.dart';
import '../models/session_models.dart';

/// Data transferred during a drag operation in the tracker
class TrackerDragData {
  final SessionExerciseModel exercise;
  final String fromSectionName;
  final int fromIndex;

  const TrackerDragData({
    required this.exercise,
    required this.fromSectionName,
    required this.fromIndex,
  });
}

/// Wrapper that makes an exercise card draggable across sections
class DraggableExerciseCard extends StatelessWidget {
  final SessionExerciseModel exercise;
  final String sectionName;
  final int index;
  final Widget child;
  final VoidCallback? onDragStarted;
  final VoidCallback? onDragEnd;

  const DraggableExerciseCard({
    super.key,
    required this.exercise,
    required this.sectionName,
    required this.index,
    required this.child,
    this.onDragStarted,
    this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<TrackerDragData>(
      data: TrackerDragData(
        exercise: exercise,
        fromSectionName: sectionName,
        fromIndex: index,
      ),
      delay: const Duration(milliseconds: 150),
      onDragStarted: onDragStarted,
      onDragEnd: (_) => onDragEnd?.call(),
      feedback: Material(
        elevation: 4.0,
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: MediaQuery.of(context).size.width - 56,
          child: Opacity(opacity: 0.95, child: child),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: child,
      ),
      child: child,
    );
  }
}
