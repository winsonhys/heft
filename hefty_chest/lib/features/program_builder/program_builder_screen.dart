import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/theme/app_colors.dart';
import 'providers/program_builder_providers.dart';
import 'widgets/workout_row.dart';
import 'widgets/workout_schedule_modal.dart';

/// Program builder screen — workout-first weekly schedule.
class ProgramBuilderScreen extends HookConsumerWidget {
  final String? programId;

  const ProgramBuilderScreen({super.key, this.programId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController();
    final isLoading = useState(false);
    final state = ref.watch(programBuilderProvider);
    final isEditing = programId != null;

    useEffect(() {
      Future<void> init() async {
        if (programId != null) {
          isLoading.value = true;
          await ref.read(programBuilderProvider.notifier).loadProgram(programId!);
          nameController.text = ref.read(programBuilderProvider).name;
          isLoading.value = false;
        } else {
          ref.read(programBuilderProvider.notifier).reset();
          nameController.text = '';
        }
      }

      init();
      return null;
    }, [programId]);

    Future<void> save() async {
      ref.read(programBuilderProvider.notifier).updateName(nameController.text);
      isLoading.value = true;
      final ok = await ref.read(programBuilderProvider.notifier).saveProgram();
      isLoading.value = false;
      if (ok && context.mounted) {
        context.go('/calendar');
      }
    }

    Future<void> openScheduleModal({int? editIndex}) async {
      final notifier = ref.read(programBuilderProvider.notifier);
      final initial = editIndex != null ? state.workouts[editIndex] : null;
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => WorkoutScheduleModal(
          initial: initial,
          onSave: (draft) {
            if (editIndex != null) {
              notifier.updateWorkoutAt(editIndex, draft);
            } else {
              notifier.addWorkout(draft);
            }
          },
          onRemove: editIndex != null
              ? () => notifier.removeWorkoutAt(editIndex)
              : null,
        ),
      );
    }

    Future<void> pickStartDate() async {
      final picked = await showDatePicker(
        context: context,
        initialDate: state.startDate,
        firstDate: DateTime(2020),
        lastDate: DateTime(2100),
      );
      if (picked != null) {
        ref.read(programBuilderProvider.notifier).setStartDate(picked);
      }
    }

    Future<void> pickDuration() async {
      final picked = await showModalBottomSheet<int>(
        context: context,
        backgroundColor: AppColors.bgPrimary,
        builder: (_) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final weeks in const [2, 4, 6, 8, 12, 16, 24])
                ListTile(
                  title: Text(
                    '$weeks weeks',
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                  trailing: weeks == state.durationWeeks
                      ? const Icon(Icons.check, color: AppColors.accentBlue)
                      : null,
                  onTap: () => Navigator.pop(context, weeks),
                ),
            ],
          ),
        ),
      );
      if (picked != null) {
        ref.read(programBuilderProvider.notifier).setDurationWeeks(picked);
      }
    }

    return FScaffold(
      header: FHeader.nested(
        title: Text(
          isEditing ? 'Edit Program' : 'Create Program',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
        suffixes: [
          FHeaderAction(
            icon: Icon(Icons.save,
                key: const Key('program_builder_save'),
                color: AppColors.accentBlue),
            onPress: save,
          ),
        ],
      ),
      child: isLoading.value
          ? const Center(child: FCircularProgress.loader())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FTextField(
                    control: .managed(
                      controller: nameController,
                      onChange: (value) => ref
                          .read(programBuilderProvider.notifier)
                          .updateName(value.text),
                    ),
                    hint: 'Program Name',
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _PickerTile(
                          key: const Key('program_builder_start_date'),
                          label: 'Start Date',
                          value: _formatHumanDate(state.startDate),
                          onTap: pickStartDate,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _PickerTile(
                          key: const Key('program_builder_duration'),
                          label: 'Duration',
                          value: '${state.durationWeeks} weeks',
                          onTap: pickDuration,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SummaryRow(state: state),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Workouts',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      GestureDetector(
                        key: const Key('program_builder_add_workout'),
                        onTap: () => openScheduleModal(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.accentBlue.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add,
                                  size: 16, color: AppColors.accentBlue),
                              SizedBox(width: 4),
                              Text(
                                'Add Workout',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.accentBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (state.workouts.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderColor),
                      ),
                      child: const Center(
                        child: Text(
                          'No workouts yet. Tap “Add Workout” to schedule one.',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                      ),
                    )
                  else
                    for (var i = 0; i < state.workouts.length; i++)
                      WorkoutRow(
                        index: i,
                        draft: state.workouts[i],
                        onTap: () => openScheduleModal(editIndex: i),
                      ),
                  if (state.error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      state.error!,
                      style: const TextStyle(color: AppColors.accentRed),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _PickerTile({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style:
                    const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final ProgramBuilderState state;

  const _SummaryRow({required this.state});

  @override
  Widget build(BuildContext context) {
    final end = state.endDate.subtract(const Duration(days: 1));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.accentBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '${state.durationWeeks} weeks · ${state.workouts.length} workouts · '
        '${_formatHumanDate(state.startDate)} → ${_formatHumanDate(end)}',
        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
    );
  }
}

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _formatHumanDate(DateTime d) =>
    '${_months[d.month - 1]} ${d.day}, ${d.year}';
