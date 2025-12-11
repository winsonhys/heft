import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/theme/app_colors.dart';
import '../../shared/widgets/bottom_nav_bar.dart';
import '../../app/router.dart';
import 'providers/calendar_providers.dart';
import 'widgets/month_header.dart';
import 'widgets/calendar_grid.dart';
import 'widgets/upcoming_list.dart';

/// Calendar screen for workout scheduling
class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  void _handleNavTap(BuildContext context, int index) {
    switch (index) {
      case NavIndex.home:
        context.goHome();
        break;
      case NavIndex.progress:
        context.goProgress();
        break;
      case NavIndex.calendar:
        // Already on calendar
        break;
      case NavIndex.profile:
        context.goProfile();
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMonth = ref.watch(currentMonthProvider);
    final calendarDataAsync = ref.watch(currentCalendarDataProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Content
            Expanded(
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
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: NavIndex.calendar,
        onTap: (index) => _handleNavTap(context, index),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderColor, width: 1),
        ),
      ),
      child: const Row(
        children: [
          Text(
            'Calendar',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _showDayDetail(BuildContext context, WidgetRef ref, DateTime date) {
    // TODO: Implement day detail modal
  }
}
