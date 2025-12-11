import 'package:flutter/material.dart';

import '../../../shared/theme/app_colors.dart';
import '../providers/workout_builder_providers.dart';
import 'exercise_item.dart';
import 'rest_item.dart';

/// Card displaying a workout section with exercises and rests
class SectionCard extends StatelessWidget {
  final BuilderSection section;
  final VoidCallback onToggleSuperset;
  final VoidCallback onDelete;
  final VoidCallback onAddExercise;
  final VoidCallback onAddRest;

  const SectionCard({
    super.key,
    required this.section,
    required this.onToggleSuperset,
    required this.onDelete,
    required this.onAddExercise,
    required this.onAddRest,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: section.isSuperset
            ? Border.all(color: AppColors.accentBlue, width: 2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    section.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                // Superset toggle
                GestureDetector(
                  onTap: onToggleSuperset,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: section.isSuperset
                          ? AppColors.accentBlue
                          : AppColors.bgPrimary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Superset',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: section.isSuperset
                            ? Colors.white
                            : AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Delete button
                GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.close,
                      size: 18,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Items
          if (section.items.isNotEmpty)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: section.items.length,
              separatorBuilder: (_, _) => Divider(
                height: 1,
                color: AppColors.borderColor,
              ),
              itemBuilder: (context, index) {
                final item = section.items[index];
                if (item.isRest) {
                  return RestItem(
                    item: item,
                    sectionId: section.id,
                  );
                }
                return ExerciseItem(
                  item: item,
                  sectionId: section.id,
                );
              },
            ),
          // Add buttons
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: _AddButton(
                    label: 'Exercise',
                    icon: Icons.fitness_center,
                    onTap: onAddExercise,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _AddButton(
                    label: 'Rest',
                    icon: Icons.timer,
                    onTap: onAddRest,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _AddButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.bgPrimary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: AppColors.textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
