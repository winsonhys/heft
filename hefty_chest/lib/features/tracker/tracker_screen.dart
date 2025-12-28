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
import 'widgets/progress_header.dart';
import 'widgets/tracker_section_card.dart';
import 'widgets/rest_timer_sheet.dart';

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
        // Start new session
        await notifier.startSession(workoutTemplateId: workoutTemplateId!);
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
              FHeaderAction.back(onPress: () => context.go('/')),
            ],
            suffixes: [
              FHeaderAction(
                icon: const Icon(Icons.close, color: AppColors.accentRed),
                onPress: discardWorkout,
              ),
              FHeaderAction(
                icon: const Icon(Icons.check, color: AppColors.accentGreen),
                onPress: finishWorkout,
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
                    return _buildSessionContent(context, ref, session);
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

  Widget _buildSessionContent(BuildContext context, WidgetRef ref, SessionModel session) {
    // Group exercises by section
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
                  itemCount: exercisesBySection.length,
                  itemBuilder: (context, sectionIndex) {
              final sectionName = exercisesBySection.keys.elementAt(sectionIndex);
              final exercises = exercisesBySection[sectionName]!;
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
                            if (isSuperset) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.accentBlue,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Superset',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => _showAddExerciseModal(context, ref, sectionName),
                              child: const Icon(
                                Icons.add_circle_outline,
                                color: AppColors.textSecondary,
                                size: 22,
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

                  // Exercises - build cards once, conditionally wrap
                  ..._buildExerciseCards(context, ref, exercises, isSuperset),
                ],
              );
            },
                ),
              ),
              // Add Section button
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

  List<Widget> _buildExerciseCards(
    BuildContext context,
    WidgetRef ref,
    List<SessionExerciseModel> exercises,
    bool isSuperset,
  ) {
    final cards = exercises.map((exercise) {
      return TrackerSectionCard(
        exercise: exercise,
        onSetCompleted: (setId, weight, reps, timeSeconds) {
          ref.read(activeSessionProvider.notifier).completeSet(
                sessionSetId: setId,
                weightKg: weight,
                reps: reps,
                timeSeconds: timeSeconds,
                toggle: true,
              );
        },
        onAddSet: () {
          ref.read(activeSessionProvider.notifier).addSet(sessionExerciseId: exercise.id);
        },
        onSetDeleted: (setId) {
          ref.read(activeSessionProvider.notifier).deleteSet(sessionSetId: setId);
        },
        onDeleteExercise: () => _confirmDeleteExercise(context, ref, exercise),
      );
    }).toList();

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
          child: Column(children: cards),
        ),
      ];
    }
    return cards;
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
