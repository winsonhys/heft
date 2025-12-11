import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../core/client.dart';
import '../providers/program_builder_providers.dart';

/// Modal for assigning workout or rest to a day
class WorkoutAssignmentModal extends ConsumerWidget {
  final int dayNumber;
  final DayAssignment? currentAssignment;
  final Function(String workoutId, String workoutName) onAssignWorkout;
  final VoidCallback onAssignRest;
  final VoidCallback onClear;

  const WorkoutAssignmentModal({
    super.key,
    required this.dayNumber,
    this.currentAssignment,
    required this.onAssignWorkout,
    required this.onAssignRest,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutsAsync = ref.watch(workoutsForProgramProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: AppColors.bgPrimary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Day $dayNumber',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (currentAssignment != null)
                  GestureDetector(
                    onTap: onClear,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentRed.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Clear',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.accentRed,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Rest day option
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: onAssignRest,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: currentAssignment?.type == DayAssignmentType.rest
                      ? AppColors.accentGreen.withValues(alpha: 0.15)
                      : AppColors.bgCard,
                  borderRadius: BorderRadius.circular(12),
                  border: currentAssignment?.type == DayAssignmentType.rest
                      ? Border.all(color: AppColors.accentGreen)
                      : null,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.accentGreen.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.bedtime,
                        color: AppColors.accentGreen,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rest Day',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'No workout scheduled',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (currentAssignment?.type == DayAssignmentType.rest)
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.accentGreen,
                        size: 20,
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Divider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(child: Divider(color: AppColors.borderColor)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'OR',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: AppColors.borderColor)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Workouts section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Assign Workout',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Workouts list
          Expanded(
            child: workoutsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.accentBlue),
              ),
              error: (_, _) => Center(
                child: Text(
                  'Failed to load workouts',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ),
              data: (workouts) {
                if (workouts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.fitness_center,
                          size: 40,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No workouts created yet',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: workouts.length,
                  itemBuilder: (context, index) {
                    final workout = workouts[index];
                    final isSelected =
                        currentAssignment?.workoutId == workout.id;
                    return _WorkoutTile(
                      workout: workout,
                      isSelected: isSelected,
                      onTap: () => onAssignWorkout(workout.id, workout.name),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutTile extends StatelessWidget {
  final WorkoutSummary workout;
  final bool isSelected;
  final VoidCallback onTap;

  const _WorkoutTile({
    required this.workout,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
              isSelected ? AppColors.accentBlue.withValues(alpha: 0.15) : AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: AppColors.accentBlue) : null,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.accentBlue.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.fitness_center,
                color: AppColors.accentBlue,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workout.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? AppColors.accentBlue
                          : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${workout.totalExercises} exercises · ${workout.totalSets} sets',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.accentBlue,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
