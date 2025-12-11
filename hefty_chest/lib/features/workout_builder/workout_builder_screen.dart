import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/theme/app_colors.dart';
import 'providers/workout_builder_providers.dart';
import 'widgets/section_card.dart';
import 'widgets/exercise_search_modal.dart';

/// Workout builder screen for creating and editing workouts
class WorkoutBuilderScreen extends ConsumerStatefulWidget {
  final String? workoutId;

  const WorkoutBuilderScreen({super.key, this.workoutId});

  @override
  ConsumerState<WorkoutBuilderScreen> createState() =>
      _WorkoutBuilderScreenState();
}

class _WorkoutBuilderScreenState extends ConsumerState<WorkoutBuilderScreen> {
  late TextEditingController _nameController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _initWorkout();
  }

  Future<void> _initWorkout() async {
    if (widget.workoutId != null) {
      setState(() => _isLoading = true);
      await ref
          .read(workoutBuilderProvider.notifier)
          .loadWorkout(widget.workoutId!);
      final state = ref.read(workoutBuilderProvider);
      _nameController.text = state.name;
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveWorkout() async {
    final notifier = ref.read(workoutBuilderProvider.notifier);
    notifier.updateName(_nameController.text);

    setState(() => _isLoading = true);
    final success = await notifier.saveWorkout();
    setState(() => _isLoading = false);

    if (success && mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workoutBuilderProvider);
    final isEditing = widget.workoutId != null;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(isEditing),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accentBlue,
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Workout Name Input
                          TextField(
                            controller: _nameController,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Workout Name',
                              hintStyle: TextStyle(
                                color: AppColors.textMuted,
                              ),
                              filled: true,
                              fillColor: AppColors.bgCard,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.all(16),
                            ),
                            onChanged: (value) {
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
                                _showExerciseSearch(context, section.id);
                              },
                              onAddRest: () {
                                ref
                                    .read(workoutBuilderProvider.notifier)
                                    .addRest(section.id);
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

  Widget _buildHeader(bool isEditing) {
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
            onTap: _saveWorkout,
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

  void _showExerciseSearch(BuildContext context, String sectionId) {
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
}
