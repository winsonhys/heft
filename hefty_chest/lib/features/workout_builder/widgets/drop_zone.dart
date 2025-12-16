import 'package:flutter/material.dart';

import '../../../shared/theme/app_colors.dart';
import 'draggable_builder_item.dart';

/// A drop zone that appears between items or at section edges
class ItemDropZone extends StatefulWidget {
  final String sectionId;
  final int targetIndex;
  final void Function(DragData dragData) onAccept;
  final bool isDragging;

  const ItemDropZone({
    super.key,
    required this.sectionId,
    required this.targetIndex,
    required this.onAccept,
    this.isDragging = false,
  });

  @override
  State<ItemDropZone> createState() => _ItemDropZoneState();
}

class _ItemDropZoneState extends State<ItemDropZone> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    // Only show expanded drop zone when actively dragging
    if (!widget.isDragging) {
      return const SizedBox(height: 0);
    }

    return DragTarget<DragData>(
      onWillAcceptWithDetails: (details) {
        // Don't accept drops at the same position
        final data = details.data;
        if (data.fromSectionId == widget.sectionId) {
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
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
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

/// Drop zone specifically for empty sections
class EmptySectionDropZone extends StatefulWidget {
  final String sectionId;
  final void Function(DragData dragData) onAccept;
  final bool isDragging;

  const EmptySectionDropZone({
    super.key,
    required this.sectionId,
    required this.onAccept,
    this.isDragging = false,
  });

  @override
  State<EmptySectionDropZone> createState() => _EmptySectionDropZoneState();
}

class _EmptySectionDropZoneState extends State<EmptySectionDropZone> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.isDragging) {
      return const SizedBox.shrink();
    }

    return DragTarget<DragData>(
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
          height: _isHovering ? 80 : 48,
          margin: const EdgeInsets.all(12),
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
            ),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isHovering ? Icons.add_circle : Icons.add_circle_outline,
                  size: 20,
                  color: AppColors.accentBlue,
                ),
                const SizedBox(width: 8),
                Text(
                  _isHovering ? 'Drop here' : 'Drop exercise here',
                  style: TextStyle(
                    color: AppColors.accentBlue,
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
