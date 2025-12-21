import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../shared/theme/app_colors.dart';
import '../../app/router.dart';
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
      try {
        await deleteWorkout(workout.id);
        ref.invalidate(workoutListProvider);
      } catch (e) {
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
                    if (workouts.isEmpty) {
                      return _buildEmptyState();
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: workouts.length,
                      itemBuilder: (context, index) {
                        final workout = workouts[index];
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.fitness_center,
              size: 32,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No workouts yet',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Create your first workout to get started',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
