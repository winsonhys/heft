import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../shared/theme/app_colors.dart';
import '../../app/router.dart';
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
            icon: const Icon(Icons.add),
            onPress: () => context.goProgramBuilder(),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month Navigation
            MonthHeader(
              month: currentMonth,
              onPrevious: () {
                ref.read(currentMonthProvider.notifier).previousMonth();
              },
              onNext: () {
                ref.read(currentMonthProvider.notifier).nextMonth();
              },
              onToday: () {
                ref.read(currentMonthProvider.notifier).goToToday();
              },
            ),

            // Calendar Grid
            calendarDataAsync.when(
              data: (data) => CalendarGrid(
                month: currentMonth,
                days: data.days,
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

            // Upcoming Section
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
                    loading: () =>
                        const UpcomingList(items: [], isLoading: true),
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
    // TODO: Implement day detail modal
  }
}
