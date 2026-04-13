import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../shared/theme/app_colors.dart';
import '../../shared/widgets/modal_sheet.dart';
import '../../app/router.dart';
import '../../core/client.dart';
import '../tracker/providers/session_providers.dart';
import 'providers/calendar_providers.dart';
import 'widgets/month_header.dart';
import 'widgets/calendar_grid.dart';
import 'widgets/upcoming_list.dart';

/// Calendar screen for workout scheduling
class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMonth = ref.watch(currentMonthProvider);
    final calendarDataAsync = ref.watch(currentCalendarDataProvider);
    final activeProgramAsync = ref.watch(activeProgramProvider);

    return FScaffold(
      header: FHeader.nested(
        title: const Text(
          'Calendar',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        suffixes: [
          FHeaderAction(
            icon: Icon(Icons.add, key: const Key('calendar_add_program')),
            onPress: () => context.goProgramBuilder(),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MonthHeader(
              month: currentMonth,
              onPrevious: () => ref.read(currentMonthProvider.notifier).previousMonth(),
              onNext: () => ref.read(currentMonthProvider.notifier).nextMonth(),
              onToday: () => ref.read(currentMonthProvider.notifier).goToToday(),
            ),
            calendarDataAsync.when(
              data: (data) => CalendarGrid(
                month: currentMonth,
                days: data.days,
                activeProgram: activeProgramAsync.value,
                onDayTap: (date) {
                  ref.read(selectedDayProvider.notifier).selectDay(date);
                  _showDayDetail(context, ref, date);
                },
              ),
              loading: () => CalendarGrid(
                month: currentMonth,
                days: const [],
                isLoading: true,
                onDayTap: (_) {},
              ),
              error: (_, _) => CalendarGrid(
                month: currentMonth,
                days: const [],
                onDayTap: (_) {},
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Upcoming',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  calendarDataAsync.when(
                    data: (data) => UpcomingList(items: data.upcoming),
                    loading: () => const UpcomingList(items: [], isLoading: true),
                    error: (_, _) => const UpcomingList(items: []),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showDayDetail(BuildContext context, WidgetRef ref, DateTime date) {
    final program = ref.read(activeProgramProvider).value;
    final scheduled = scheduledWorkoutsFor(program, date);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _DayDetailSheet(date: date, scheduled: scheduled),
    );
  }
}

class _DayDetailSheet extends ConsumerWidget {
  final DateTime date;
  final List<ProgramWorkout> scheduled;

  const _DayDetailSheet({required this.date, required this.scheduled});

  Future<void> _start(BuildContext context, WidgetRef ref, ProgramWorkout w) async {
    final active = await ref.read(hasActiveSessionProvider.future);
    if (active != null) {
      if (context.mounted) {
        showFToast(
          context: context,
          title: const Text('Please finish your current workout first'),
          icon: const Icon(Icons.warning_amber_rounded),
        );
      }
      return;
    }
    if (context.mounted) {
      Navigator.pop(context);
      context.goNewSession(workoutId: w.workoutTemplateId);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgPrimary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DragHandle(),
          const SizedBox(height: 12),
          Text(
            _formatHumanDate(date),
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          if (scheduled.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Rest day — nothing scheduled.',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ),
            )
          else
            for (final w in scheduled)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        w.workoutName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _start(context, ref, w),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.accentBlue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Start',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
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

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _formatHumanDate(DateTime d) =>
    '${_months[d.month - 1]} ${d.day}, ${d.year}';
