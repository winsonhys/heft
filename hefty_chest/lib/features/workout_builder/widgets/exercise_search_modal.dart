import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../core/client.dart';
import '../providers/workout_builder_providers.dart';

/// Modal for searching and selecting exercises
class ExerciseSearchModal extends ConsumerStatefulWidget {
  final Function(Exercise) onSelect;

  const ExerciseSearchModal({
    super.key,
    required this.onSelect,
  });

  @override
  ConsumerState<ExerciseSearchModal> createState() =>
      _ExerciseSearchModalState();
}

class _ExerciseSearchModalState extends ConsumerState<ExerciseSearchModal> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    // Reset search query
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(exerciseSearchQueryProvider.notifier).clear();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exercises = ref.watch(filteredExercisesProvider);
    final exercisesAsync = ref.watch(exerciseListProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add Exercise',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                // Search bar
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    ref.read(exerciseSearchQueryProvider.notifier).setQuery(value);
                  },
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search exercises...',
                    hintStyle: TextStyle(color: AppColors.textMuted),
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppColors.textMuted,
                    ),
                    filled: true,
                    fillColor: AppColors.bgCard,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Exercise list
          Expanded(
            child: exercisesAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.accentBlue),
              ),
              error: (_, _) => Center(
                child: Text(
                  'Failed to load exercises',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ),
              data: (_) {
                if (exercises.isEmpty) {
                  return Center(
                    child: Text(
                      'No exercises found',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = exercises[index];
                    return _ExerciseTile(
                      exercise: exercise,
                      onTap: () => widget.onSelect(exercise),
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

class _ExerciseTile extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback onTap;

  const _ExerciseTile({
    required this.exercise,
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
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Type icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getTypeColor().withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getTypeIcon(),
                size: 20,
                color: _getTypeColor(),
              ),
            ),
            const SizedBox(width: 12),
            // Exercise info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (exercise.categoryName.isNotEmpty)
                    Text(
                      exercise.categoryName,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                ],
              ),
            ),
            // Type badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getTypeColor().withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _getTypeName(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: _getTypeColor(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor() {
    switch (exercise.exerciseType) {
      case ExerciseType.EXERCISE_TYPE_WEIGHT_REPS:
        return AppColors.accentBlue;
      case ExerciseType.EXERCISE_TYPE_TIME:
        return AppColors.accentOrange;
      case ExerciseType.EXERCISE_TYPE_BODYWEIGHT_REPS:
        return AppColors.accentGreen;
      default:
        return AppColors.textMuted;
    }
  }

  IconData _getTypeIcon() {
    switch (exercise.exerciseType) {
      case ExerciseType.EXERCISE_TYPE_WEIGHT_REPS:
        return Icons.fitness_center;
      case ExerciseType.EXERCISE_TYPE_TIME:
        return Icons.timer;
      case ExerciseType.EXERCISE_TYPE_BODYWEIGHT_REPS:
        return Icons.accessibility_new;
      default:
        return Icons.sports;
    }
  }

  String _getTypeName() {
    switch (exercise.exerciseType) {
      case ExerciseType.EXERCISE_TYPE_WEIGHT_REPS:
        return 'Weight';
      case ExerciseType.EXERCISE_TYPE_TIME:
        return 'Time';
      case ExerciseType.EXERCISE_TYPE_BODYWEIGHT_REPS:
        return 'Bodyweight';
      default:
        return 'Other';
    }
  }
}
