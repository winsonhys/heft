import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../gen/session.pb.dart';
import '../../../gen/common.pbenum.dart';
import 'set_row.dart';

/// Expandable exercise card with sets table
class ExerciseCard extends StatefulWidget {
  final SessionExercise exercise;
  final Function(String setId, double? weight, int? reps, int? timeSeconds) onSetCompleted;

  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.onSetCompleted,
  });

  @override
  State<ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<ExerciseCard> {
  bool _isExpanded = true;

  bool get _isTimeBased {
    return widget.exercise.exerciseType == ExerciseType.EXERCISE_TYPE_TIME;
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
            onTap: () => setState(() => _isExpanded = !_isExpanded),
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
                  GestureDetector(
                    onTap: () {
                      // TODO: Show exercise options menu
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.more_vert,
                        size: 18,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expanded content
          if (_isExpanded) ...[
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
                    key: ValueKey(set.id),
                    set: set,
                    isTimeBased: _isTimeBased,
                    onComplete: widget.onSetCompleted,
                  )),
                ],
              ),
            ),

            // Add set button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: FButton(
                style: FButtonStyle.ghost(),
                onPress: () {
                  // TODO: Add set functionality
                },
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
