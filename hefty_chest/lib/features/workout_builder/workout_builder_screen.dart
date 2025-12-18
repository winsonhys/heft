import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/theme/app_colors.dart';
import 'providers/workout_builder_providers.dart';
import 'widgets/draggable_builder_item.dart';
import 'widgets/section_card.dart';
import 'widgets/exercise_search_modal.dart';

/// Workout builder screen for creating and editing workouts
class WorkoutBuilderScreen extends HookConsumerWidget {
  final String? workoutId;

  const WorkoutBuilderScreen({super.key, this.workoutId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController();
    final isLoading = useState(false);
    final isDragging = useState(false);
    final state = ref.watch(workoutBuilderProvider);
    final isEditing = workoutId != null;

    // Initialize workout on mount
    useEffect(() {
      if (workoutId != null) {
        // Defer to avoid modifying provider during build
        Future.microtask(() async {
          
          await ref.read(workoutBuilderProvider.notifier).loadWorkout(workoutId!);
          final loadedState = ref.read(workoutBuilderProvider);
          nameController.text = loadedState.name;
        });
      }
      return null;
    }, [workoutId]);

    Future<void> saveWorkout() async {
      final notifier = ref.read(workoutBuilderProvider.notifier);
      notifier.updateName(nameController.text);

      isLoading.value = true;
      final success = await notifier.saveWorkout();
      isLoading.value = false;

      if (success && context.mounted) {
        context.pop();
      }
    }

    void showExerciseSearch(String sectionId) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => ExerciseSearchModal(
          onSelect: (exercise) {
            ref
                .read(workoutBuilderProvider.notifier)
                .addExercise(sectionId, exercise);
            Navigator.pop(context);
          },
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context, isEditing, saveWorkout),

            // Content
            Expanded(
              child: isLoading.value
                  ? const Center(
                      child: FProgress(),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Workout Name Input
                          FTextField(
                            controller: nameController,
                            hint: 'Workout Name',
                            onChange: (value) {
                              ref
                                  .read(workoutBuilderProvider.notifier)
                                  .updateName(value);
                            },
                          ),

                          const SizedBox(height: 24),

                          // Sections
                          ...state.sections.map((section) {
                            return SectionCard(
                              key: ValueKey(section.id),
                              section: section,
                              isDragging: isDragging.value,
                              onToggleSuperset: () {
                                ref
                                    .read(workoutBuilderProvider.notifier)
                                    .toggleSuperset(section.id);
                              },
                              onDelete: () {
                                ref
                                    .read(workoutBuilderProvider.notifier)
                                    .deleteSection(section.id);
                              },
                              onAddExercise: () {
                                showExerciseSearch(section.id);
                              },
                              onAddRest: () {
                                ref
                                    .read(workoutBuilderProvider.notifier)
                                    .addRest(section.id);
                              },
                              onSectionNameChanged: (name) {
                                ref
                                    .read(workoutBuilderProvider.notifier)
                                    .updateSectionName(section.id, name);
                              },
                              onDragStarted: () {
                                isDragging.value = true;
                              },
                              onDragEnd: () {
                                isDragging.value = false;
                              },
                              onItemDropped: (DragData dragData, int targetIndex) {
                                ref
                                    .read(workoutBuilderProvider.notifier)
                                    .moveItem(
                                      itemId: dragData.item.id,
                                      fromSectionId: dragData.fromSectionId,
                                      toSectionId: section.id,
                                      targetIndex: targetIndex,
                                    );
                              },
                            );
                          }),

                          const SizedBox(height: 16),

                          // Add Section Button
                          GestureDetector(
                            onTap: () {
                              ref
                                  .read(workoutBuilderProvider.notifier)
                                  .addSection();
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.borderColor,
                                  style: BorderStyle.solid,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add,
                                    color: AppColors.textMuted,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Add Section',
                                    style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isEditing, VoidCallback onSave) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(
                Icons.chevron_left,
                color: AppColors.textPrimary,
                size: 24,
              ),
            ),
          ),
          Text(
            isEditing ? 'Edit Workout' : 'Create Workout',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          GestureDetector(
            onTap: onSave,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.accentBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Save',
                style: TextStyle(
                  fontSize: 14,
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
}
