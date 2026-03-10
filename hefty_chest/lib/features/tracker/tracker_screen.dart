import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/theme/app_colors.dart';
import '../../shared/utils/formatters.dart';
import '../../shared/widgets/confirm_dialog.dart';
import '../../shared/widgets/floating_session_widget.dart';
import '../workout_builder/widgets/exercise_search_modal.dart';
import 'models/session_models.dart';
import 'providers/session_providers.dart';
import 'widgets/draggable_exercise_card.dart';
import 'widgets/exercise_drop_zone.dart';
import 'widgets/progress_header.dart';
import 'widgets/tracker_section_card.dart';
import 'widgets/rest_timer_sheet.dart';
import 'widgets/rest_item_card.dart';

/// Tracker screen for active workout session
class TrackerScreen extends HookConsumerWidget {
  final String? workoutTemplateId;
  final String? sessionId;

  const TrackerScreen({
    super.key,
    this.workoutTemplateId,
    this.sessionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(true);
    final showRestTimer = useState(false);
    final restTimeRemaining = useState(120);
    final nextExerciseName = useState('');
    final nextSetNumber = useState(1);
    final elapsedSeconds = useState(0);
    final isDragging = useState(false);

    final sessionAsync = ref.watch(activeSessionProvider);

    // Timer effect for elapsed time
    useEffect(() {
      final session = sessionAsync.value;
      if (session == null || session.startedAt == null) {
        return null;
      }

      // Calculate initial elapsed time
      final startedAt = session.startedAt!;
      elapsedSeconds.value = DateTime.now().difference(startedAt).inSeconds;

      // Set up periodic timer
      final timer = Timer.periodic(const Duration(seconds: 1), (_) {
        elapsedSeconds.value = DateTime.now().difference(startedAt).inSeconds;
      });

      return timer.cancel;
    }, [sessionAsync.value?.id]);

    // Hide floating widget when on tracker screen, show when leaving
    // Capture notifier before disposal since ref is invalid in cleanup
    final floatingNotifier = ref.read(floatingWidgetVisibleProvider.notifier);
    useEffect(() {
      Future.microtask(() {
        floatingNotifier.hide();
      });
      return () {
        Future.microtask(() {
          floatingNotifier.show();
        });
      };
    }, [floatingNotifier]);

    // Function to initialize/retry session
    Future<void> initSession() async {
      isLoading.value = true;
      final notifier = ref.read(activeSessionProvider.notifier);

      if (sessionId != null) {
        // Resume existing session
        await notifier.loadSession(sessionId: sessionId!);
      } else if (workoutTemplateId != null) {
        // Start new session from template
        await notifier.startSession(workoutTemplateId: workoutTemplateId!);
      } else {
        // Start empty session
        await notifier.startSession(name: 'Quick Workout');
      }

      if (context.mounted) {
        isLoading.value = false;
      }
    }

    // Initialize session on mount
    useEffect(() {
      Future.microtask(() => initSession());
      return null;
    }, [sessionId, workoutTemplateId]);

    void hideRestTimer() {
      showRestTimer.value = false;
    }

    Future<void> finishWorkout() async {
      final confirm = await showConfirmDialog(
        context: context,
        title: 'Finish Workout?',
        message: 'Are you sure you want to finish this workout?',
        confirmLabel: 'Finish',
      );

      if (confirm && context.mounted) {
        await ref.read(activeSessionProvider.notifier).finishSession();
        if (context.mounted) {
          context.go('/');
        }
      }
    }

    Future<void> discardWorkout() async {
      final confirm = await showConfirmDialog(
        context: context,
        title: 'Discard Workout?',
        message: 'Are you sure you want to discard this workout? All progress will be lost.',
        confirmLabel: 'Discard',
        isDestructive: true,
      );

      if (confirm && context.mounted) {
        await ref.read(activeSessionProvider.notifier).abandonSession();
        if (context.mounted) {
          context.go('/');
        }
      }
    }

    Future<void> goBackHome() async {
      // Force sync any pending changes before leaving
      await ref.read(activeSessionProvider.notifier).cleanup();
      if (context.mounted) {
        context.go('/');
      }
    }

    return Stack(
      children: [
        FScaffold(
          header: FHeader.nested(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  sessionAsync.value?.name.isNotEmpty == true
                      ? sessionAsync.value!.name
                      : 'Workout',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (sessionAsync.value != null) ...[
                  const SizedBox(width: 12),
                  Text(
                    formatDuration(elapsedSeconds.value),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ],
            ),
            prefixes: [
              FHeaderAction.back(onPress: goBackHome),
            ],
            suffixes: [
              GestureDetector(
                onTap: discardWorkout,
                child: const Text(
                  'Discard',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.accentRed,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: finishWorkout,
                child: const Text(
                  'Finish',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.accentGreen,
                  ),
                ),
              ),
            ],
          ),
          child: isLoading.value
              ? const Center(
                  child: FCircularProgress.loader(),
                )
              : sessionAsync.when(
                  data: (session) {
                    if (session == null) {
                      return _buildNoSession(context);
                    }
                    return _buildSessionContent(
                      context,
                      ref,
                      session,
                      isDragging,
                      onTriggerRestTimer: (int duration, String exerciseName, int setNumber) {
                        restTimeRemaining.value = duration;
                        nextExerciseName.value = exerciseName;
                        nextSetNumber.value = setNumber;
                        showRestTimer.value = true;
                      },
                    );
                  },
                  loading: () => const Center(
                    child: FCircularProgress.loader(),
                  ),
                  error: (error, _) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: AppColors.accentRed,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load session, ${error.toString()}',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        FButton(
                          style: FButtonStyle.ghost(),
                          onPress: initSession,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
        ),

        // Rest Timer Bottom Sheet
        if (showRestTimer.value)
          RestTimerSheet(
            initialTime: restTimeRemaining.value,
            nextExerciseName: nextExerciseName.value,
            nextSetNumber: nextSetNumber.value,
            onSkip: hideRestTimer,
            onComplete: hideRestTimer,
          ),
      ],
    );
  }

  Widget _buildNoSession(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.fitness_center,
            size: 64,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 16),
          const Text(
            'No active session',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          FButton(
            style: FButtonStyle.ghost(),
            onPress: () => context.go('/'),
            child: const Text('Go back home'),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionContent(
    BuildContext context,
    WidgetRef ref,
    SessionModel session,
    ValueNotifier<bool> isDragging, {
    required void Function(int duration, String exerciseName, int setNumber) onTriggerRestTimer,
  }) {
    // Create unified list of items (exercises and rest items) for each section
    final itemsBySection = <String, List<_TrackerItem>>{};

    for (final exercise in session.exercises) {
      final sectionName = exercise.sectionName.isEmpty ? 'Exercises' : exercise.sectionName;
      itemsBySection.putIfAbsent(sectionName, () => []).add(
        _TrackerItem.exercise(exercise),
      );
    }

    for (final restItem in session.restItems.where((r) => r.restDurationSeconds > 0)) {
      final sectionName = restItem.sectionName.isEmpty ? 'Exercises' : restItem.sectionName;
      itemsBySection.putIfAbsent(sectionName, () => []).add(
        _TrackerItem.rest(restItem),
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
        // Progress Card - watches sessionProgressProvider directly
        const ProgressHeader(),

        // Exercise List
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
              // Check if any exercise in this section has a superset_id
              final isSuperset = exercises.any((e) => e.supersetId != null);

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
                                      color: isSuperset ? Colors.white : AppColors.textMuted,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Superset',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: isSuperset ? Colors.white : AppColors.textMuted,
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
                              onTap: () => _showAddExerciseModal(context, ref, sectionName),
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
                              onTap: () => _confirmDeleteSection(context, ref, sectionName),
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

                  // Items - build cards once, conditionally wrap
                  ..._buildSectionItems(
                    context,
                    ref,
                    items,
                    exercises,
                    isSuperset,
                    sectionName,
                    isDragging,
                    onTriggerRestTimer: onTriggerRestTimer,
                  ),
                ],
              );
            },
                ),
              ),
              // New Section drop zone (only shown when dragging)
              NewSectionDropZone(
                isDragging: isDragging.value,
                onAccept: (dragData) {
                  _showNewSectionDialog(context, ref, dragData.exercise.id);
                },
              ),
              // Add Section button
              if (!isDragging.value)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: GestureDetector(
                    onTap: () => _showAddSectionFlow(context, ref),
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
                ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSectionItems(
    BuildContext context,
    WidgetRef ref,
    List<_TrackerItem> items,
    List<SessionExerciseModel> exercises,
    bool isSuperset,
    String sectionName,
    ValueNotifier<bool> isDragging, {
    required void Function(int duration, String exerciseName, int setNumber) onTriggerRestTimer,
  }) {
    final widgets = <Widget>[];
    int exerciseIndex = 0;

    for (int i = 0; i < items.length; i++) {
      final item = items[i];

      if (item.isExercise) {
        final exercise = item.exercise!;

        // Add drop zone before each exercise
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

        // Build the card
        final card = TrackerSectionCard(
          exercise: exercise,
          onSetCompleted: (setId, weight, reps, timeSeconds) {
            final notifier = ref.read(activeSessionProvider.notifier);

            // Check if completing (not un-completing)
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

            // Show rest timer only when completing (not un-completing) and rest is configured
            if (isCompleting) {
              final info = notifier.getSetCompletionInfo(setId);
              if (info != null && info.restDurationSeconds > 0) {
                onTriggerRestTimer(info.restDurationSeconds, info.nextExerciseName, info.nextSetNumber);
              }
            }
          },
          onAddSet: () {
            ref.read(activeSessionProvider.notifier).addSet(sessionExerciseId: exercise.id);
          },
          onSetDeleted: (setId) {
            ref.read(activeSessionProvider.notifier).deleteSet(sessionSetId: setId);
          },
          onDeleteExercise: () => _confirmDeleteExercise(context, ref, exercise),
        );

        // Wrap with draggable
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
        // Rest item
        final restItem = item.restItem!;
        widgets.add(
          RestItemCard(
            restItem: restItem,
            onComplete: () {
              ref.read(activeSessionProvider.notifier).completeRestItem(
                restItemId: restItem.id,
              );
            },
            onSkip: () {
              ref.read(activeSessionProvider.notifier).completeRestItem(
                restItemId: restItem.id,
                toggle: true,
              );
            },
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

  void _showAddExerciseModal(BuildContext context, WidgetRef ref, String sectionName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ExerciseSearchModal(
        onSelect: (exercise) {
          ref.read(activeSessionProvider.notifier).addExercise(
            exerciseId: exercise.id,
            exerciseName: exercise.name,
            exerciseType: exercise.exerciseType,
            sectionName: sectionName,
          );
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showAddSectionFlow(BuildContext context, WidgetRef ref) async {
    // Step 1: Get section name via dialog
    final sectionNameController = TextEditingController();
    final sectionName = await showFDialog<String>(
      context: context,
      builder: (context, style, animation) {
        return FDialog(
          style: style, // ignore: implicit_call_tearoffs
          animation: animation,
          title: const Text('New Section'),
          body: FTextField(
            control: .managed(controller: sectionNameController),
            hint: 'Section name',
            autofocus: true,
          ),
          actions: [
            FButton(
              style: FButtonStyle.ghost(),
              onPress: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FButton(
              onPress: () => Navigator.pop(context, sectionNameController.text.trim()),
              child: const Text('Next'),
            ),
          ],
        );
      },
    );

    if (sectionName == null || sectionName.isEmpty || !context.mounted) return;

    // Step 2: Show exercise picker with new section name
    _showAddExerciseModal(context, ref, sectionName);
  }

  void _showNewSectionDialog(BuildContext context, WidgetRef ref, String exerciseId) async {
    final sectionNameController = TextEditingController();
    final sectionName = await showFDialog<String>(
      context: context,
      builder: (context, style, animation) {
        return FDialog(
          style: style,
          animation: animation,
          title: const Text('New Section'),
          body: FTextField(
            control: .managed(controller: sectionNameController),
            hint: 'Section name',
            autofocus: true,
          ),
          actions: [
            FButton(
              style: FButtonStyle.ghost(),
              onPress: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FButton(
              onPress: () => Navigator.pop(context, sectionNameController.text.trim()),
              child: const Text('Create'),
            ),
          ],
        );
      },
    );

    if (sectionName == null || sectionName.isEmpty) return;

    ref.read(activeSessionProvider.notifier).createNewSectionWithExercise(
      exerciseId: exerciseId,
      sectionName: sectionName,
    );
  }

  Future<void> _confirmDeleteExercise(BuildContext context, WidgetRef ref, SessionExerciseModel exercise) async {
    final confirm = await showConfirmDialog(
      context: context,
      title: 'Delete Exercise?',
      message: 'Are you sure you want to delete "${exercise.exerciseName}"?',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if (confirm) {
      ref.read(activeSessionProvider.notifier).deleteExercise(sessionExerciseId: exercise.id);
    }
  }

  Future<void> _confirmDeleteSection(BuildContext context, WidgetRef ref, String sectionName) async {
    final confirm = await showConfirmDialog(
      context: context,
      title: 'Delete Section?',
      message: 'Are you sure you want to delete the "$sectionName" section and all its exercises?',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if (confirm) {
      ref.read(activeSessionProvider.notifier).deleteSection(sectionName: sectionName);
    }
  }
}

/// Internal class to represent either an exercise or a rest item in the tracker
class _TrackerItem {
  final SessionExerciseModel? exercise;
  final SessionRestItemModel? restItem;

  const _TrackerItem.exercise(this.exercise) : restItem = null;
  const _TrackerItem.rest(this.restItem) : exercise = null;

  bool get isExercise => exercise != null;
  bool get isRest => restItem != null;

  int get displayOrder => exercise?.displayOrder ?? restItem?.displayOrder ?? 0;
}
