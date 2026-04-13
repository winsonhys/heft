import 'package:flutter/material.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../core/client.dart';

/// Single day cell in the calendar grid.
///
/// Renders the date number plus dot indicators:
/// - Orange dot: a session was completed on this date
/// - Blue dot: this date has at least one workout scheduled by the active program
/// - Green dot: legacy "rest day" indicator from `GetCalendarMonth`
class CalendarDayCell extends StatelessWidget {
  final int dayNumber;
  final CalendarDay? dayData;
  final int scheduledCount;
  final bool isToday;
  final bool isCurrentMonth;
  final VoidCallback? onTap;

  const CalendarDayCell({
    super.key,
    required this.dayNumber,
    this.dayData,
    this.scheduledCount = 0,
    this.isToday = false,
    this.isCurrentMonth = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasCompleted = dayData != null && dayData!.workoutCount > 0;
    final hasScheduled = scheduledCount > 0;
    final isRestDay = dayData != null && dayData!.isRestDay;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isToday ? AppColors.accentBlue.withValues(alpha: 0.15) : null,
          borderRadius: BorderRadius.circular(8),
          border: hasScheduled && !isToday
              ? Border.all(color: AppColors.accentBlue.withValues(alpha: 0.4))
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dayNumber.toString(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
                color: isCurrentMonth
                    ? (isToday ? AppColors.accentBlue : AppColors.textPrimary)
                    : AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (hasCompleted) _EventDot(color: AppColors.accentOrange),
                if (hasScheduled) _EventDot(color: AppColors.accentBlue),
                if (isRestDay && !hasCompleted)
                  _EventDot(color: AppColors.accentGreen),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EventDot extends StatelessWidget {
  final Color color;

  const _EventDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1),
      width: 6,
      height: 6,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
