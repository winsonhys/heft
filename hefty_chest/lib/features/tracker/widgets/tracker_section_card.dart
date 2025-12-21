import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../gen/common.pbenum.dart';
import '../models/session_models.dart';
import 'set_row.dart';

/// Expandable section card with sets table for tracker
class TrackerSectionCard extends StatefulWidget {
  final SessionExerciseModel exercise;
  final Function(String setId, double? weight, int? reps, int? timeSeconds) onSetCompleted;
  final VoidCallback? onAddSet;
  final Function(String setId)? onSetDeleted;
  final VoidCallback? onDeleteExercise;

  const TrackerSectionCard({
    super.key,
    required this.exercise,
    required this.onSetCompleted,
    this.onAddSet,
    this.onSetDeleted,
    this.onDeleteExercise,
  });

  @override
  State<TrackerSectionCard> createState() => _TrackerSectionCardState();
}

class _TrackerSectionCardState extends State<TrackerSectionCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  bool _isExpanded = true;

  bool get _isTimeBased {
    return widget.exercise.exerciseType == ExerciseType.EXERCISE_TYPE_TIME;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
      value: 1.0, // Start expanded
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          GestureDetector(
            onTap: _toggle,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.exercise.exerciseName,
                      style: TextStyle(
                        fontSize: _isExpanded ? 16 : 14,
                        fontWeight: _isExpanded ? FontWeight.w600 : FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    iconSize: 18,
                    icon: const Icon(
                      Icons.more_vert,
                      size: 18,
                      color: AppColors.textMuted,
                    ),
                    color: AppColors.bgCard,
                    onSelected: (value) {
                      if (value == 'delete' && widget.onDeleteExercise != null) {
                        widget.onDeleteExercise!();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, size: 18, color: AppColors.accentRed),
                            SizedBox(width: 8),
                            Text('Delete Exercise', style: TextStyle(color: AppColors.accentRed)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Expanded content with FCollapsible
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) => FCollapsible(
              value: _animation.value,
              child: child!,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Notes/description
                if (widget.exercise.notes.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.bgCardInner,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.exercise.notes,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),

                // Sets table
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Column(
                    children: [
                      // Header row
                      _buildTableHeader(),

                      // Set rows
                      ...widget.exercise.sets.map((set) => SetRow(
                        key: ValueKey(set.id.isNotEmpty ? set.id : 'new-set-${set.setNumber}'),
                        set: set,
                        isTimeBased: _isTimeBased,
                        onComplete: widget.onSetCompleted,
                        onDelete: widget.onSetDeleted != null
                            ? () => widget.onSetDeleted!(set.id)
                            : null,
                      )),
                    ],
                  ),
                ),

                // Add set button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: FButton(
                    style: FButtonStyle.ghost(),
                    onPress: widget.onAddSet,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 16),
                        SizedBox(width: 4),
                        Text('Add Set'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const SizedBox(
            width: 36,
            child: Text(
              'SET',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(
            width: 52,
            child: Text(
              'PR',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 6),
          if (_isTimeBased)
            const Expanded(
              flex: 2,
              child: Text(
                'TIME',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                  letterSpacing: 0.5,
                ),
              ),
            )
          else ...[
            const SizedBox(
              width: 52,
              child: Text(
                'KG',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 6),
            const SizedBox(
              width: 52,
              child: Text(
                'REPS',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
          const SizedBox(width: 6),
          const SizedBox(width: 32), // Complete button space
          const SizedBox(width: 28), // More button space
        ],
      ),
    );
  }
}
