import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/theme/app_colors.dart';
import 'providers/program_builder_providers.dart';
import 'widgets/duration_selector.dart';
import 'widgets/program_summary_card.dart';
import 'widgets/week_navigation.dart';
import 'widgets/day_card.dart';
import 'widgets/workout_assignment_modal.dart';

/// Program builder screen for creating training programs
class ProgramBuilderScreen extends ConsumerStatefulWidget {
  final String? programId;

  const ProgramBuilderScreen({super.key, this.programId});

  @override
  ConsumerState<ProgramBuilderScreen> createState() =>
      _ProgramBuilderScreenState();
}

class _ProgramBuilderScreenState extends ConsumerState<ProgramBuilderScreen> {
  late TextEditingController _nameController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _initProgram();
  }

  Future<void> _initProgram() async {
    if (widget.programId != null) {
      setState(() => _isLoading = true);
      await ref
          .read(programBuilderProvider.notifier)
          .loadProgram(widget.programId!);
      final state = ref.read(programBuilderProvider);
      _nameController.text = state.name;
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveProgram() async {
    final notifier = ref.read(programBuilderProvider.notifier);
    notifier.updateName(_nameController.text);

    setState(() => _isLoading = true);
    final success = await notifier.saveProgram();
    setState(() => _isLoading = false);

    if (success && mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(programBuilderProvider);
    final currentWeek = ref.watch(currentWeekProvider);
    final isEditing = widget.programId != null;

    // Calculate days for current week
    final startDay = (currentWeek - 1) * 7 + 1;
    final endDay = (startDay + 6).clamp(1, state.totalDays);
    final daysInWeek = <int>[];
    for (int i = startDay; i <= endDay; i++) {
      daysInWeek.add(i);
    }

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
                          // Program Name Input
                          TextField(
                            controller: _nameController,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Program Name',
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
                                  .read(programBuilderProvider.notifier)
                                  .updateName(value);
                            },
                          ),

                          const SizedBox(height: 24),

                          // Duration Selector
                          const Text(
                            'Duration',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          DurationSelector(
                            weeks: state.durationWeeks,
                            days: state.durationDays,
                            onChanged: (weeks, days) {
                              ref
                                  .read(programBuilderProvider.notifier)
                                  .setDuration(weeks, days);
                            },
                          ),

                          const SizedBox(height: 24),

                          // Summary Card
                          ProgramSummaryCard(
                            totalDays: state.totalDays,
                            workoutDays: state.workoutDays,
                            restDays: state.restDays,
                          ),

                          const SizedBox(height: 24),

                          // Week Navigation
                          WeekNavigation(
                            currentWeek: currentWeek,
                            totalWeeks: state.totalWeeks,
                            onPrevious: currentWeek > 1
                                ? () {
                                    ref.read(currentWeekProvider.notifier).previousWeek();
                                  }
                                : null,
                            onNext: currentWeek < state.totalWeeks
                                ? () {
                                    ref.read(currentWeekProvider.notifier).nextWeek();
                                  }
                                : null,
                          ),

                          const SizedBox(height: 16),

                          // Days Grid
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: daysInWeek.map((dayNumber) {
                              final assignment =
                                  state.dayAssignments[dayNumber];
                              return DayCard(
                                dayNumber: dayNumber,
                                assignment: assignment,
                                onTap: () {
                                  _showWorkoutAssignment(context, dayNumber);
                                },
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 16),

                          // Week Actions
                          Row(
                            children: [
                              Expanded(
                                child: _buildActionButton(
                                  'Fill empty with rest',
                                  () {
                                    ref
                                        .read(programBuilderProvider.notifier)
                                        .fillWeekWithRest(currentWeek);
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildActionButton(
                                  'Clear week',
                                  () {
                                    ref
                                        .read(programBuilderProvider.notifier)
                                        .clearWeek(currentWeek);
                                  },
                                ),
                              ),
                            ],
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
            isEditing ? 'Edit Program' : 'Create Program',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          GestureDetector(
            onTap: _saveProgram,
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

  Widget _buildActionButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  void _showWorkoutAssignment(BuildContext context, int dayNumber) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WorkoutAssignmentModal(
        dayNumber: dayNumber,
        currentAssignment: ref.read(programBuilderProvider).dayAssignments[dayNumber],
        onAssignWorkout: (workoutId, workoutName) {
          ref
              .read(programBuilderProvider.notifier)
              .assignWorkout(dayNumber, workoutId, workoutName);
          Navigator.pop(context);
        },
        onAssignRest: () {
          ref.read(programBuilderProvider.notifier).assignRest(dayNumber);
          Navigator.pop(context);
        },
        onClear: () {
          ref.read(programBuilderProvider.notifier).clearDay(dayNumber);
          Navigator.pop(context);
        },
      ),
    );
  }
}
