import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../shared/theme/app_colors.dart';
import '../../app/router.dart';
import '../../core/logging.dart';
import '../tracker/providers/session_providers.dart';
import 'providers/home_providers.dart';
import 'widgets/quick_stats_row.dart';
import 'widgets/workout_card.dart';

/// Home screen displaying workout list and quick stats
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _startWorkout(
    BuildContext context,
    WidgetRef ref,
    String workoutId,
  ) async {
    // Check if there's already an active session
    final activeSession = await ref.read(hasActiveSessionProvider.future);
    if (activeSession != null) {
      if (context.mounted) {
        showFToast(
          context: context,
          title: const Text('Please finish your current workout first'),
          icon: const Icon(Icons.warning_amber_rounded),
        );
      }
      return;
    }

    if (context.mounted) {
      context.goNewSession(workoutId: workoutId);
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    dynamic workout,
  ) async {
    final confirmed = await showFDialog<bool>(
      context: context,
      builder: (context, style, animation) => FDialog(
        style: style, // ignore: implicit_call_tearoffs
        animation: animation,
        direction: Axis.horizontal,
        title: const Text('Delete Workout'),
        body: Text(
          'Are you sure you want to delete "${workout.name}"? This action cannot be undone.',
        ),
        actions: [
          FButton(
            style: FButtonStyle.ghost(),
            onPress: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FButton(
            style: FButtonStyle.destructive(),
            onPress: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      logHome.info('Deleting workout: ${workout.id}');
      try {
        await deleteWorkout(workout.id);
        ref.invalidate(workoutListProvider);
        logHome.info('Workout deleted: ${workout.id}');
      } catch (e, st) {
        logHome.severe('Failed to delete workout: ${workout.id}', e, st);
        if (context.mounted) {
          showFToast(
            context: context,
            title: Text('Failed to delete workout: $e'),
            icon: const Icon(Icons.error_outline),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutsAsync = ref.watch(workoutListProvider);
    final statsAsync = ref.watch(dashboardStatsProvider);

    return Stack(
      children: [
        FScaffold(
          header: FHeader(
            title: Row(
              children: [
                Icon(
                  Icons.fitness_center,
                  color: AppColors.accentBlue,
                  size: 28,
                ),
                const SizedBox(width: 10),
                Text(
                  'Heft',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subtitle
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Text(
                  'Ready to crush your workout?',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textMuted,
                  ),
                ),
              ),

              // Quick Stats
              statsAsync.when(
                data: (stats) => QuickStatsRow(
                  totalWorkouts: stats.totalWorkouts,
                  thisWeek: stats.workoutsThisWeek,
                  streak: stats.currentStreak,
                ),
                loading: () => const QuickStatsRow(
                  totalWorkouts: 0,
                  thisWeek: 0,
                  streak: 0,
                  isLoading: true,
                ),
                error: (_, _) => const QuickStatsRow(
                  totalWorkouts: 0,
                  thisWeek: 0,
                  streak: 0,
                ),
              ),

              // Section Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'My Workouts',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              // Workout List
              Expanded(
                child: workoutsAsync.when(
                  data: (workouts) {
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: workouts.length + 1, // +1 for Quick Start card
                      itemBuilder: (context, index) {
                        // First item is the Quick Start card
                        if (index == 0) {
                          return _buildQuickStartCard(context, ref);
                        }
                        // Offset by 1 for workout cards
                        final workout = workouts[index - 1];
                        return WorkoutCard(
                          workout: workout,
                          onStart: () => _startWorkout(context, ref, workout.id),
                          onEdit: () => context.goEditWorkout(workoutId: workout.id),
                          onDelete: () => _confirmDelete(context, ref, workout),
                        );
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
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: AppColors.accentRed,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load workouts',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        FButton(
                          style: FButtonStyle.ghost(),
                          onPress: () => ref.invalidate(workoutListProvider),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // FAB
        Positioned(
          right: 20,
          bottom: 20,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.accentBlue,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentBlue.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: Colors.white, size: 24),
              onPressed: () => context.goWorkoutBuilder(),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _startEmptyWorkout(BuildContext context, WidgetRef ref) async {
    // Check if there's already an active session
    final activeSession = await ref.read(hasActiveSessionProvider.future);
    if (activeSession != null) {
      if (context.mounted) {
        showFToast(
          context: context,
          title: const Text('Please finish your current workout first'),
          icon: const Icon(Icons.warning_amber_rounded),
        );
      }
      return;
    }

    if (context.mounted) {
      context.goEmptySession();
    }
  }

  Widget _buildQuickStartCard(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.accentBlue.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.add,
              color: AppColors.accentBlue,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Start',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Start an empty workout',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          FButton(
            onPress: () => _startEmptyWorkout(context, ref),
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }

}
