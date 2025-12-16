import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/theme/app_colors.dart';
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

    final sessionAsync = ref.watch(activeSessionProvider);

    // Initialize session on mount
    useEffect(() {
      Future<void> initSession() async {
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
      Future.microtask(() => initSession());
      return null;
    }, [sessionId, workoutTemplateId]);

    void hideRestTimer() {
      showRestTimer.value = false;
    }

    Future<void> finishWorkout() async {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.bgCard,
          title: const Text(
            'Finish Workout?',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: const Text(
            'Are you sure you want to finish this workout?',
            style: TextStyle(color: AppColors.textSecondary),
          ),
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

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Header
                _buildHeader(context, finishWorkout),

                // Content
                Expanded(
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
                                  onPress: () {
                                    isLoading.value = true;
                                    // Re-trigger init
                                  },
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ],
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
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, VoidCallback onFinish) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => context.go('/'),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(
                Icons.chevron_left,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
          ),
          const Text(
            'Workout',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          GestureDetector(
            onTap: onFinish,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accentGreen,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Finish',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
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
                              final scaffoldMessenger =
                                  ScaffoldMessenger.of(context);
                              final isPR = await ref
                                  .read(activeSessionProvider.notifier)
                                  .completeSet(
                                    sessionSetId: setId,
                                    weightKg: weight,
                                    reps: reps,
                                    timeSeconds: timeSeconds,
                                  );
                              if (isPR && context.mounted) {
                                scaffoldMessenger.showSnackBar(
                                  const SnackBar(
                                    content: Text('New Personal Record! 🎉'),
                                    backgroundColor: AppColors.accentGreen,
                                  ),
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
                          final scaffoldMessenger =
                              ScaffoldMessenger.of(context);
                          final isPR = await ref
                              .read(activeSessionProvider.notifier)
                              .completeSet(
                                sessionSetId: setId,
                                weightKg: weight,
                                reps: reps,
                                timeSeconds: timeSeconds,
                              );
                          if (isPR && context.mounted) {
                            scaffoldMessenger.showSnackBar(
                              const SnackBar(
                                content: Text('New Personal Record! 🎉'),
                                backgroundColor: AppColors.accentGreen,
                              ),
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
