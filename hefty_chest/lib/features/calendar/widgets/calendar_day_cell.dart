import 'package:flutter/material.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../core/client.dart';

/// Single day cell in calendar grid
class CalendarDayCell extends StatelessWidget {
  final int dayNumber;
  final CalendarDay? dayData;
  final bool isToday;
  final bool isCurrentMonth;
  final VoidCallback? onTap;

  const CalendarDayCell({
    super.key,
    required this.dayNumber,
    this.dayData,
    this.isToday = false,
    this.isCurrentMonth = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasWorkout = dayData != null && dayData!.workoutCount > 0;
    final hasScheduled = dayData != null && dayData!.hasScheduled;
    final isRestDay = dayData != null && dayData!.isRestDay;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isToday ? AppColors.accentBlue.withValues(alpha: 0.15) : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Day number
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
            // Event dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (hasWorkout)
                  _EventDot(color: AppColors.accentOrange), // Completed workout
                if (hasScheduled && !hasWorkout)
                  _EventDot(color: AppColors.accentBlue), // Scheduled
                if (isRestDay)
                  _EventDot(color: AppColors.accentGreen), // Rest day
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
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
