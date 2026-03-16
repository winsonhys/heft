import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../shared/utils/formatters.dart';
import '../models/session_models.dart';

/// Info-only card displaying a rest item's duration.
/// The rest timer auto-triggers via the onSetCompleted callback chain:
/// - Superset: triggers when a round completes
/// - Non-superset: triggers when an exercise's last set completes
class RestItemCard extends HookWidget {
  final SessionRestItemModel restItem;
  final bool isSuperset;

  const RestItemCard({
    super.key,
    required this.restItem,
    this.isSuperset = false,
  });

  @override
  Widget build(BuildContext context) {
    final label = isSuperset
        ? 'Rest Between Rounds — ${formatDuration(restItem.restDurationSeconds)}'
        : 'Rest — ${formatDuration(restItem.restDurationSeconds)}';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.bgCard.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.accentGreen.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.timer_outlined,
              color: AppColors.accentGreen,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
