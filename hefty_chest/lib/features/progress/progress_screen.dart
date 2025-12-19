import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../shared/theme/app_colors.dart';
import '../../shared/widgets/bottom_nav_bar.dart';
import '../../app/router.dart';
import 'providers/progress_providers.dart';
import 'widgets/summary_cards_row.dart';
import 'widgets/weekly_activity_chart.dart';
import 'widgets/pr_list.dart';
import 'widgets/exercise_progress_section.dart';

/// Progress screen displaying analytics and workout statistics
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  void _handleNavTap(BuildContext context, int index) {
    switch (index) {
      case NavIndex.home:
        context.goHome();
        break;
      case NavIndex.progress:
        // Already on progress
        break;
      case NavIndex.calendar:
        context.goCalendar();
        break;
      case NavIndex.profile:
        context.goProfile();
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(progressStatsProvider);
    final weeklyAsync = ref.watch(weeklyActivityProvider);
    final prsAsync = ref.watch(personalRecordsProvider);

    return FScaffold(
      header: FHeader(
        title: const Text(
          'Progress',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      footer: BottomNavBar(
        selectedIndex: NavIndex.progress,
        onTap: (index) => _handleNavTap(context, index),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Summary Cards
            statsAsync.when(
              data: (stats) => SummaryCardsRow(
                thisWeek: stats.workoutsThisWeek,
                streak: stats.currentStreak,
                totalWorkouts: stats.totalWorkouts,
              ),
              loading: () => const SummaryCardsRow(
                thisWeek: 0,
                streak: 0,
                totalWorkouts: 0,
                isLoading: true,
              ),
              error: (_, _) => const SummaryCardsRow(
                thisWeek: 0,
                streak: 0,
                totalWorkouts: 0,
              ),
            ),

            const SizedBox(height: 24),

            // Weekly Activity Chart
            const Text(
              'Weekly Activity',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            weeklyAsync.when(
              data: (weekly) => WeeklyActivityChart(weeklyData: weekly),
              loading: () => const WeeklyActivityChart(
                weeklyData: [],
                isLoading: true,
              ),
              error: (_, _) => const WeeklyActivityChart(weeklyData: []),
            ),

            const SizedBox(height: 24),

            // Personal Records
            const Text(
              'Recent PRs',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            prsAsync.when(
              data: (prs) => PrList(records: prs),
              loading: () => const PrList(records: [], isLoading: true),
              error: (_, _) => const PrList(records: []),
            ),

            const SizedBox(height: 24),

            // Exercise Progress
            const ExerciseProgressSection(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
