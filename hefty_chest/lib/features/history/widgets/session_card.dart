import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/client.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/utils/formatters.dart';

/// Card displaying a completed session summary
class SessionCard extends StatelessWidget {
  final SessionSummary session;
  final VoidCallback onTap;

  const SessionCard({
    super.key,
    required this.session,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final completedAt = session.completedAt.toDateTime().toLocal();
    final dateStr = DateFormat('MMM d, yyyy').format(completedAt);
    final completionPercent = session.totalSets > 0
        ? ((session.completedSets / session.totalSets) * 100).round()
        : 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 6),
                Text(
                  dateStr,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Workout name
            Text(
              session.name.isNotEmpty ? session.name : 'Workout',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),

            // Stats row
            Row(
              children: [
                Text(
                  formatDuration(session.durationSeconds),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  '•',
                  style: TextStyle(color: AppColors.textMuted),
                ),
                const SizedBox(width: 8),
                Text(
                  '${session.completedSets}/${session.totalSets} sets',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  '•',
                  style: TextStyle(color: AppColors.textMuted),
                ),
                const SizedBox(width: 8),
                Text(
                  '$completionPercent%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: completionPercent >= 80
                        ? AppColors.accentGreen
                        : completionPercent >= 50
                            ? AppColors.accentOrange
                            : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
