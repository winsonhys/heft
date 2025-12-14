import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../shared/theme/app_colors.dart';
import '../providers/workout_builder_providers.dart';
import 'exercise_item.dart';
import 'rest_item.dart';

/// Card displaying a workout section with exercises and rests
class SectionCard extends HookWidget {
  final BuilderSection section;
  final VoidCallback onToggleSuperset;
  final VoidCallback onDelete;
  final VoidCallback onAddExercise;
  final VoidCallback onAddRest;
  final ValueChanged<String> onSectionNameChanged;

  const SectionCard({
    super.key,
    required this.section,
    required this.onToggleSuperset,
    required this.onDelete,
    required this.onAddExercise,
    required this.onAddRest,
    required this.onSectionNameChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isEditing = useState(false);
    final nameController = useTextEditingController(text: section.name);
    final focusNode = useFocusNode();

    // Sync controller when section name changes externally
    useEffect(() {
      if (!isEditing.value) {
        nameController.text = section.name;
      }
      return null;
    }, [section.name]);

    void finishEditing() {
      final newName = nameController.text.trim();
      if (newName.isNotEmpty && newName != section.name) {
        onSectionNameChanged(newName);
      } else if (newName.isEmpty) {
        nameController.text = section.name;
      }
      isEditing.value = false;
    }

    void startEditing() {
      isEditing.value = true;
      focusNode.requestFocus();
    }

    // Handle focus changes
    useEffect(() {
      void onFocusChange() {
        if (!focusNode.hasFocus && isEditing.value) {
          finishEditing();
        }
      }

      focusNode.addListener(onFocusChange);
      return () => focusNode.removeListener(onFocusChange);
    }, []);

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
                  child: isEditing.value
                      ? TextField(
                          controller: nameController,
                          focusNode: focusNode,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            border: InputBorder.none,
                          ),
                          onSubmitted: (_) => finishEditing(),
                        )
                      : GestureDetector(
                          onTap: startEditing,
                          child: Text(
                            section.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
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
              separatorBuilder: (context, index) => Divider(
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
