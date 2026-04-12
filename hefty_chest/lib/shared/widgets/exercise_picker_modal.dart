import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';

import '../../core/client.dart';
import '../theme/app_colors.dart';
import '../utils/exercise_type_utils.dart';

/// Shared exercise picker modal — pure UI, no providers or RPC calls.
///
/// Displays a searchable, scrollable list of exercises in a bottom sheet.
/// Supports optional selection highlighting via [selectedId].
class ExercisePickerModal extends HookWidget {
  final String title;
  final List<Exercise> exercises;
  final String? selectedId;
  final Function(Exercise) onSelect;
  final ValueChanged<String>? onSearchChanged;

  const ExercisePickerModal({
    super.key,
    this.title = 'Select Exercise',
    required this.exercises,
    this.selectedId,
    required this.onSelect,
    this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final searchController = useTextEditingController();
    final filteredExercises = useState(exercises);

    List<Exercise> applyFilter(String query) {
      if (query.isEmpty) return exercises;
      final lowerQuery = query.toLowerCase();
      return exercises
          .where((e) => e.name.toLowerCase().contains(lowerQuery))
          .toList();
    }

    // Re-sync when the exercise list changes from outside.
    useEffect(() {
      filteredExercises.value = applyFilter(searchController.text);
      return null;
    }, [exercises]);

    void onSearchInput(String query) {
      onSearchChanged?.call(query);
      filteredExercises.value = applyFilter(query);
    }

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
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                FTextField(
                  control: .managed(
                    controller: searchController,
                    onChange: (value) => onSearchInput(value.text),
                  ),
                  hint: 'Search exercises...',
                ),
              ],
            ),
          ),
          // Exercise list
          Expanded(
            child: filteredExercises.value.isEmpty
                ? Center(
                    child: Text(
                      'No exercises found',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredExercises.value.length,
                    itemBuilder: (context, index) {
                      final exercise = filteredExercises.value[index];
                      final isSelected = exercise.id == selectedId;
                      return _ExerciseTile(
                        exercise: exercise,
                        isSelected: isSelected,
                        onTap: () => onSelect(exercise),
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
  final bool isSelected;
  final VoidCallback onTap;

  const _ExerciseTile({
    required this.exercise,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final typeColor = exerciseTypeColor(exercise.exerciseType);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accentBlue.withValues(alpha: 0.1)
              : AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: AppColors.accentBlue) : null,
        ),
        child: Row(
          children: [
            // Type icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                exerciseTypeIcon(exercise.exerciseType),
                size: 20,
                color: typeColor,
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
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? AppColors.accentBlue
                          : AppColors.textPrimary,
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
                color: typeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                exerciseTypeName(exercise.exerciseType),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: typeColor,
                ),
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.check_circle,
                color: AppColors.accentBlue,
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
