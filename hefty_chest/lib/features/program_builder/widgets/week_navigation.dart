import 'package:flutter/material.dart';

import '../../../shared/theme/app_colors.dart';

/// Navigation header for week selection
class WeekNavigation extends StatelessWidget {
  final int currentWeek;
  final int totalWeeks;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const WeekNavigation({
    super.key,
    required this.currentWeek,
    required this.totalWeeks,
    this.onPrevious,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Previous button
        GestureDetector(
          onTap: onPrevious,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: onPrevious != null ? AppColors.bgCard : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.chevron_left,
              size: 24,
              color: onPrevious != null
                  ? AppColors.textPrimary
                  : AppColors.textMuted.withValues(alpha: 0.3),
            ),
          ),
        ),
        // Week label
        Column(
          children: [
            Text(
              'Week $currentWeek',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'of $totalWeeks weeks',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        // Next button
        GestureDetector(
          onTap: onNext,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: onNext != null ? AppColors.bgCard : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.chevron_right,
              size: 24,
              color: onNext != null
                  ? AppColors.textPrimary
                  : AppColors.textMuted.withValues(alpha: 0.3),
            ),
          ),
        ),
      ],
    );
  }
}
