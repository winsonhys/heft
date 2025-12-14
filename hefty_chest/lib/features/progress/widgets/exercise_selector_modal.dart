import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../core/client.dart';

/// Modal for selecting an exercise from the library
class ExerciseSelectorModal extends HookWidget {
  final List<Exercise> exercises;
  final String? selectedId;
  final Function(String) onSelect;

  const ExerciseSelectorModal({
    super.key,
    required this.exercises,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final searchController = useTextEditingController();
    final filteredExercises = useState(exercises);

    void filterExercises(String query) {
      if (query.isEmpty) {
        filteredExercises.value = exercises;
      } else {
        filteredExercises.value = exercises
            .where((e) => e.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
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
                const Text(
                  'Select Exercise',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                // Search bar
                TextField(
                  controller: searchController,
                  onChanged: filterExercises,
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
            child: filteredExercises.value.isEmpty
                ? Center(
                    child: Text(
                      'No exercises found',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 14,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredExercises.value.length,
                    itemBuilder: (context, index) {
                      final exercise = filteredExercises.value[index];
                      final isSelected = exercise.id == selectedId;
                      return GestureDetector(
                        onTap: () => onSelect(exercise.id),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.accentBlue.withValues(alpha: 0.1)
                                : AppColors.bgCard,
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected
                                ? Border.all(color: AppColors.accentBlue)
                                : null,
                          ),
                          child: Row(
                            children: [
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
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
