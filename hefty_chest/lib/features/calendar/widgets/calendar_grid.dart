import 'package:flutter/material.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../core/client.dart';
import 'calendar_day_cell.dart';

/// Calendar grid showing days of the month
class CalendarGrid extends StatelessWidget {
  final DateTime month;
  final List<CalendarDay> days;
  final bool isLoading;
  final Function(DateTime) onDayTap;

  const CalendarGrid({
    super.key,
    required this.month,
    required this.days,
    this.isLoading = false,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // First day of month
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    // Day of week for first day (0 = Monday, 6 = Sunday)
    final startingWeekday = (firstDayOfMonth.weekday - 1) % 7;

    // Build map of date -> CalendarDay for quick lookup
    final dayMap = <String, CalendarDay>{};
    for (final day in days) {
      dayMap[day.date] = day;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Week day headers
          Row(
            children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                .map((day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          // Calendar grid
          if (isLoading)
            SizedBox(
              height: 240,
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.accentBlue,
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
              ),
              itemCount: 42, // 6 weeks
              itemBuilder: (context, index) {
                final dayOffset = index - startingWeekday;
                final date = DateTime(month.year, month.month, dayOffset + 1);

                // Check if this date is in current month
                final isCurrentMonth = date.month == month.month;

                // Build date string for lookup
                final dateStr =
                    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                final dayData = dayMap[dateStr];

                final isToday = date.year == today.year &&
                    date.month == today.month &&
                    date.day == today.day;

                return CalendarDayCell(
                  dayNumber: date.day,
                  dayData: dayData,
                  isToday: isToday,
                  isCurrentMonth: isCurrentMonth,
                  onTap: isCurrentMonth ? () => onDayTap(date) : null,
                );
              },
            ),
        ],
      ),
    );
  }
}
