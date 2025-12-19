import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/theme/app_colors.dart';
import '../../shared/utils/formatters.dart';
import '../../shared/widgets/floating_session_widget.dart';
import '../../gen/session.pb.dart';
import 'providers/session_providers.dart';
import 'widgets/progress_header.dart';
import 'widgets/exercise_card.dart';
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
      if (session == null || !session.hasStartedAt()) {
        return null;
      }

      // Calculate initial elapsed time
      final startedAt = session.startedAt.toDateTime();
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
      final confirm = await showFDialog<bool>(
        context: context,
        builder: (context, style, animation) => FDialog(
          style: style, // ignore: implicit_call_tearoffs
          animation: animation,
          direction: Axis.horizontal,
          title: const Text('Finish Workout?'),
          body: const Text('Are you sure you want to finish this workout?'),
          actions: [
            FButton(
              style: FButtonStyle.ghost(),
              onPress: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FButton(
              onPress: () => Navigator.pop(context, true),
              child: const Text('Finish'),
            ),
          ],
        ),
      );

      if (confirm == true && context.mounted) {
        await ref.read(activeSessionProvider.notifier).finishSession();
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
                const Text(
                  'Workout',
                  style: TextStyle(
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
                icon: const Icon(Icons.check, color: AppColors.accentGreen),
                onPress: finishWorkout,
              ),
            ],
          ),
          child: isLoading.value
              ? const Center(
                  child: FProgress(),
                )
              : sessionAsync.when(
                  data: (session) {
                    if (session == null) {
                      return _buildNoSession(context);
                    }
                    return _buildSessionContent(context, ref, session);
                  },
                  loading: () => const Center(
                    child: FProgress(),
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
                          'Failed to load session',
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

  Widget _buildSessionContent(BuildContext context, WidgetRef ref, Session session) {
    final completedSets = session.completedSets;
    final totalSets = session.totalSets;
    final progress = totalSets > 0 ? completedSets / totalSets : 0.0;

    // Group exercises by section
    final exercisesBySection = <String, List<SessionExercise>>{};
    for (final exercise in session.exercises) {
      final sectionName = exercise.sectionName.isEmpty ? 'Exercises' : exercise.sectionName;
      exercisesBySection.putIfAbsent(sectionName, () => []).add(exercise);
    }

    return Column(
      children: [
        // Progress Card
        ProgressHeader(
          progress: progress,
          completedSets: completedSets,
          totalSets: totalSets,
        ),

        // Exercise List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: exercisesBySection.length,
            itemBuilder: (context, sectionIndex) {
              final sectionName = exercisesBySection.keys.elementAt(sectionIndex);
              final exercises = exercisesBySection[sectionName]!;
              final isSuperset = exercises.length > 1 &&
                  sectionName.toLowerCase().contains('superset');

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Header
                  Padding(
                    padding: EdgeInsets.fromLTRB(4, sectionIndex == 0 ? 0 : 20, 0, 12),
                    child: Text(
                      sectionName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),

                  // Exercises
                  if (isSuperset)
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: AppColors.supersetBorder,
                            width: 3,
                          ),
                        ),
                      ),
                      margin: const EdgeInsets.only(left: 4),
                      padding: const EdgeInsets.only(left: 12),
                      child: Column(
                        children: exercises.map((exercise) {
                          return ExerciseCard(
                            exercise: exercise,
                            onSetCompleted: (setId, weight, reps, timeSeconds) async {
                              final isPR = await ref
                                  .read(activeSessionProvider.notifier)
                                  .completeSet(
                                    sessionSetId: setId,
                                    weightKg: weight,
                                    reps: reps,
                                    timeSeconds: timeSeconds,
                                    toggle: true,
                                  );
                              if (isPR && context.mounted) {
                                showFToast(
                                  context: context,
                                  title: const Text('New Personal Record!'),
                                  icon: const Icon(Icons.emoji_events),
                                );
                              }
                            },
                          );
                        }).toList(),
                      ),
                    )
                  else
                    ...exercises.map((exercise) {
                      return ExerciseCard(
                        exercise: exercise,
                        onSetCompleted: (setId, weight, reps, timeSeconds) async {
                          final isPR = await ref
                              .read(activeSessionProvider.notifier)
                              .completeSet(
                                sessionSetId: setId,
                                weightKg: weight,
                                reps: reps,
                                timeSeconds: timeSeconds,
                                toggle: true,
                              );
                          if (isPR && context.mounted) {
                            showFToast(
                              context: context,
                              title: const Text('New Personal Record!'),
                              icon: const Icon(Icons.emoji_events),
                            );
                          }
                        },
                      );
                    }),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
