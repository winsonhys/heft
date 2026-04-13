import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/modal_sheet.dart';
import '../providers/program_builder_providers.dart';
import 'weekday_chip_row.dart';

/// Bottom-sheet modal: pick a workout template + the weekdays it runs on.
///
/// Used for both new entries and editing existing ones (pass [initial]).
class WorkoutScheduleModal extends ConsumerStatefulWidget {
  final ProgramWorkoutDraft? initial;
  final ValueChanged<ProgramWorkoutDraft> onSave;
  final VoidCallback? onRemove;

  const WorkoutScheduleModal({
    super.key,
    this.initial,
    required this.onSave,
    this.onRemove,
  });

  @override
  ConsumerState<WorkoutScheduleModal> createState() => _WorkoutScheduleModalState();
}

class _WorkoutScheduleModalState extends ConsumerState<WorkoutScheduleModal> {
  String? _workoutTemplateId;
  String _workoutName = '';
  late Set<int> _days;

  @override
  void initState() {
    super.initState();
    _workoutTemplateId = widget.initial?.workoutTemplateId;
    _workoutName = widget.initial?.workoutName ?? '';
    _days = {...?widget.initial?.days};
  }

  bool get _canSave => _workoutTemplateId != null && _days.isNotEmpty;

  void _save() {
    if (!_canSave) return;
    widget.onSave(ProgramWorkoutDraft(
      id: widget.initial?.id,
      workoutTemplateId: _workoutTemplateId!,
      workoutName: _workoutName,
      days: _days,
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final workoutsAsync = ref.watch(workoutsForProgramProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppColors.bgPrimary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const Padding(padding: EdgeInsets.only(top: 12), child: DragHandle()),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.initial == null ? 'Add Workout' : 'Edit Workout',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (widget.onRemove != null)
                  GestureDetector(
                    onTap: () {
                      widget.onRemove?.call();
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Remove',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.accentRed,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Days of week',
                  style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                ),
                const SizedBox(height: 8),
                WeekdayChipRow(
                  selected: _days,
                  onChanged: (next) => setState(() => _days = next),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                'Workout',
                style: TextStyle(fontSize: 13, color: AppColors.textMuted),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: workoutsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.accentBlue),
              ),
              error: (_, __) => const Center(
                child: Text('Failed to load workouts',
                    style: TextStyle(color: AppColors.textMuted)),
              ),
              data: (workouts) {
                if (workouts.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'No workouts yet — create one first to schedule it in a program.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: workouts.length,
                  itemBuilder: (context, index) {
                    final w = workouts[index];
                    final selected = _workoutTemplateId == w.id;
                    return GestureDetector(
                      onTap: () => setState(() {
                        _workoutTemplateId = w.id;
                        _workoutName = w.name;
                      }),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.accentBlue.withValues(alpha: 0.15)
                              : AppColors.bgCard,
                          borderRadius: BorderRadius.circular(12),
                          border: selected
                              ? Border.all(color: AppColors.accentBlue)
                              : null,
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.fitness_center,
                                color: AppColors.accentBlue, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                w.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            if (selected)
                              const Icon(Icons.check_circle,
                                  color: AppColors.accentBlue, size: 20),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: SizedBox(
              width: double.infinity,
              child: GestureDetector(
                key: const Key('workout_schedule_save'),
                onTap: _canSave ? _save : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: _canSave
                        ? AppColors.accentBlue
                        : AppColors.bgCard,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Save',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _canSave
                          ? AppColors.textPrimary
                          : AppColors.textMuted,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
