import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../shared/theme/app_colors.dart';
import '../models/session_models.dart';
import '../providers/session_providers.dart';
import 'draggable_exercise_card.dart';
import 'exercise_drop_zone.dart';
import 'progress_header.dart';
import 'rest_item_card.dart';
import 'tracker_dialogs.dart';
import 'tracker_section_card.dart';

/// Internal class to represent either an exercise or a rest item in the tracker
class TrackerItem {
  final SessionExerciseModel? exercise;
  final SessionRestItemModel? restItem;

  const TrackerItem.exercise(this.exercise) : restItem = null;
  const TrackerItem.rest(this.restItem) : exercise = null;

  bool get isExercise => exercise != null;
  bool get isRest => restItem != null;

  int get displayOrder => exercise?.displayOrder ?? restItem?.displayOrder ?? 0;
}

/// Builds the session content: progress header + section list + add section button.
class TrackerSectionList extends StatelessWidget {
  final SessionModel session;
  final ValueNotifier<bool> isDragging;
  final void Function(int duration, String exerciseName, int setNumber) onTriggerRestTimer;

  const TrackerSectionList({
    super.key,
    required this.session,
    required this.isDragging,
    required this.onTriggerRestTimer,
  });

  @override
  Widget build(BuildContext context) {
    // Create unified list of items (exercises and rest items) for each section
    final itemsBySection = <String, List<TrackerItem>>{};

    for (final exercise in session.exercises) {
      final sectionName = exercise.sectionName.isEmpty ? 'Exercises' : exercise.sectionName;
      itemsBySection.putIfAbsent(sectionName, () => []).add(
        TrackerItem.exercise(exercise),
      );
    }

    for (final restItem in session.restItems.where((r) => r.restDurationSeconds > 0)) {
      final sectionName = restItem.sectionName.isEmpty ? 'Exercises' : restItem.sectionName;
      itemsBySection.putIfAbsent(sectionName, () => []).add(
        TrackerItem.rest(restItem),
      );
    }

    // Sort items within each section by displayOrder
    for (final items in itemsBySection.values) {
      items.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    }

    // Also maintain backwards-compatible exercises-only map for superset logic
    final exercisesBySection = <String, List<SessionExerciseModel>>{};
    for (final exercise in session.exercises) {
      final sectionName = exercise.sectionName.isEmpty ? 'Exercises' : exercise.sectionName;
      exercisesBySection.putIfAbsent(sectionName, () => []).add(exercise);
    }

    return Column(
      children: [
        const ProgressHeader(),
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: itemsBySection.length,
                  itemBuilder: (context, sectionIndex) {
                    final sectionName = itemsBySection.keys.elementAt(sectionIndex);
                    final items = itemsBySection[sectionName]!;
                    final exercises = exercisesBySection[sectionName] ?? [];
                    final isSuperset = exercises.any((e) => e.supersetId != null);

                    return _buildSection(
                      context,
                      sectionIndex,
                      sectionName,
                      items,
                      exercises,
                      isSuperset,
                    );
                  },
                ),
              ),
              // New Section drop zone (only shown when dragging)
              _buildNewSectionDropZone(context),
              // Add Section button
              if (!isDragging.value)
                _buildAddSectionButton(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context,
    int sectionIndex,
    String sectionName,
    List<TrackerItem> items,
    List<SessionExerciseModel> exercises,
    bool isSuperset,
  ) {
    return Consumer(
      builder: (context, ref, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Padding(
              padding: EdgeInsets.fromLTRB(4, sectionIndex == 0 ? 0 : 20, 4, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        sectionName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          ref.read(activeSessionProvider.notifier).toggleSectionSuperset(
                            sectionName: sectionName,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSuperset
                                ? AppColors.accentPurple
                                : AppColors.bgPrimary,
                            borderRadius: BorderRadius.circular(12),
                            border: isSuperset
                                ? null
                                : Border.all(color: AppColors.borderColor),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isSuperset ? Icons.link : Icons.link_off,
                                size: 12,
                                color: isSuperset ? AppColors.textPrimary : AppColors.textMuted,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Superset',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: isSuperset ? AppColors.textPrimary : AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => showAddExerciseModal(context, ref, sectionName),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.bgPrimary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add, size: 14, color: AppColors.textMuted),
                              SizedBox(width: 4),
                              Text(
                                'Exercise',
                                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () => confirmDeleteSection(context, ref, sectionName),
                        child: const Icon(
                          Icons.delete_outline,
                          color: AppColors.textMuted,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Items
            ..._buildSectionItems(
              context,
              ref,
              items,
              exercises,
              isSuperset,
              sectionName,
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildSectionItems(
    BuildContext context,
    WidgetRef ref,
    List<TrackerItem> items,
    List<SessionExerciseModel> exercises,
    bool isSuperset,
    String sectionName,
  ) {
    final widgets = <Widget>[];
    int exerciseIndex = 0;

    for (int i = 0; i < items.length; i++) {
      final item = items[i];

      if (item.isExercise) {
        final exercise = item.exercise!;

        widgets.add(
          ExerciseDropZone(
            sectionName: sectionName,
            targetIndex: exerciseIndex,
            isDragging: isDragging.value,
            onAccept: (dragData) {
              ref.read(activeSessionProvider.notifier).moveExercise(
                exerciseId: dragData.exercise.id,
                toSectionName: sectionName,
                targetIndex: exerciseIndex,
              );
            },
          ),
        );

        final card = TrackerSectionCard(
          exercise: exercise,
          onSetCompleted: (setId, weight, reps, timeSeconds) {
            final notifier = ref.read(activeSessionProvider.notifier);

            final session = ref.read(activeSessionProvider).value;
            final isCompleting = session?.exercises
                .expand((e) => e.sets)
                .where((s) => s.id == setId)
                .firstOrNull
                ?.completedAt == null;

            notifier.completeSet(
              sessionSetId: setId,
              weightKg: weight,
              reps: reps,
              timeSeconds: timeSeconds,
              toggle: true,
            );

            if (isCompleting) {
              final supersetInfo = notifier.getSupersetRoundCompletionInfo(setId);
              if (supersetInfo != null && supersetInfo.restDurationSeconds > 0) {
                onTriggerRestTimer(supersetInfo.restDurationSeconds, supersetInfo.nextExerciseName, supersetInfo.nextSetNumber);
              } else {
                final info = notifier.getSetCompletionInfo(setId);
                if (info != null && info.restDurationSeconds > 0) {
                  onTriggerRestTimer(info.restDurationSeconds, info.nextExerciseName, info.nextSetNumber);
                } else {
                  final sectionInfo = notifier.getExerciseCompletionRestInfo(setId);
                  if (sectionInfo != null && sectionInfo.restDurationSeconds > 0) {
                    onTriggerRestTimer(sectionInfo.restDurationSeconds, sectionInfo.nextExerciseName, sectionInfo.nextSetNumber);
                  }
                }
              }
            }
          },
          onAddSet: () {
            ref.read(activeSessionProvider.notifier).addSet(sessionExerciseId: exercise.id);
          },
          onSetDeleted: (setId) {
            ref.read(activeSessionProvider.notifier).deleteSet(sessionSetId: setId);
          },
          onDeleteExercise: () => confirmDeleteExercise(context, ref, exercise),
          onNotesChanged: (setId, notes) {
            ref.read(activeSessionProvider.notifier).updateSetNotes(
              sessionSetId: setId,
              notes: notes,
            );
          },
        );

        widgets.add(
          DraggableExerciseCard(
            exercise: exercise,
            sectionName: sectionName,
            index: exerciseIndex,
            onDragStarted: () => isDragging.value = true,
            onDragEnd: () => isDragging.value = false,
            child: card,
          ),
        );

        exerciseIndex++;
      } else {
        widgets.add(
          RestItemCard(
            restItem: item.restItem!,
            isSuperset: isSuperset,
          ),
        );
      }
    }

    // Add drop zone after the last exercise
    widgets.add(
      ExerciseDropZone(
        sectionName: sectionName,
        targetIndex: exercises.length,
        isDragging: isDragging.value,
        onAccept: (dragData) {
          ref.read(activeSessionProvider.notifier).moveExercise(
            exerciseId: dragData.exercise.id,
            toSectionName: sectionName,
            targetIndex: exercises.length,
          );
        },
      ),
    );

    if (isSuperset) {
      return [
        Container(
          decoration: const BoxDecoration(
            border: Border(
              left: BorderSide(color: AppColors.supersetBorder, width: 3),
            ),
          ),
          margin: const EdgeInsets.only(left: 4),
          padding: const EdgeInsets.only(left: 12),
          child: Column(children: widgets),
        ),
      ];
    }
    return widgets;
  }

  Widget _buildNewSectionDropZone(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        return NewSectionDropZone(
          isDragging: isDragging.value,
          onAccept: (dragData) {
            showNewSectionDialog(context, ref, dragData.exercise.id);
          },
        );
      },
    );
  }

  Widget _buildAddSectionButton(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: GestureDetector(
            onTap: () => showAddSectionFlow(context, ref),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: AppColors.textSecondary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Add Section',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
