import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/theme/app_colors.dart';
import '../../gen/session.pb.dart';
import 'providers/session_providers.dart';
import 'widgets/progress_header.dart';
import 'widgets/exercise_card.dart';
import 'widgets/rest_timer_sheet.dart';

/// Tracker screen for active workout session
class TrackerScreen extends ConsumerStatefulWidget {
  final String? workoutTemplateId;
  final String? sessionId;

  const TrackerScreen({
    super.key,
    this.workoutTemplateId,
    this.sessionId,
  });

  @override
  ConsumerState<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends ConsumerState<TrackerScreen> {
  bool _isLoading = true;
  bool _showRestTimer = false;
  final int _restTimeRemaining = 120;
  final String _nextExerciseName = '';
  final int _nextSetNumber = 1;

  @override
  void initState() {
    super.initState();
    _initSession();
  }

  Future<void> _initSession() async {
    final notifier = ref.read(activeSessionProvider.notifier);

    if (widget.sessionId != null) {
      // Resume existing session
      await notifier.loadSession(sessionId: widget.sessionId!);
    } else if (widget.workoutTemplateId != null) {
      // Start new session
      await notifier.startSession(workoutTemplateId: widget.workoutTemplateId!);
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _hideRestTimer() {
    setState(() => _showRestTimer = false);
  }

  Future<void> _finishWorkout() async {
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
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentGreen,
            ),
            child: const Text('Finish'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await ref.read(activeSessionProvider.notifier).finishSession();
      if (mounted) {
        context.go('/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionAsync = ref.watch(activeSessionProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Header
                _buildHeader(),

                // Content
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.accentBlue,
                          ),
                        )
                      : sessionAsync.when(
                          data: (session) {
                            if (session == null) {
                              return _buildNoSession();
                            }
                            return _buildSessionContent(session);
                          },
                          loading: () => const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.accentBlue,
                            ),
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
                                TextButton(
                                  onPressed: _initSession,
                                  child: const Text(
                                    'Retry',
                                    style: TextStyle(color: AppColors.accentBlue),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ],
            ),

            // Rest Timer Bottom Sheet
            if (_showRestTimer)
              RestTimerSheet(
                initialTime: _restTimeRemaining,
                nextExerciseName: _nextExerciseName,
                nextSetNumber: _nextSetNumber,
                onSkip: _hideRestTimer,
                onComplete: _hideRestTimer,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
            onTap: _finishWorkout,
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

  Widget _buildNoSession() {
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
          TextButton(
            onPressed: () => context.go('/'),
            child: const Text(
              'Go back home',
              style: TextStyle(color: AppColors.accentBlue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionContent(Session session) {
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
                              if (isPR && mounted) {
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
                          if (isPR && mounted) {
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
