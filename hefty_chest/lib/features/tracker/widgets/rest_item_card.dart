import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../shared/utils/formatters.dart';
import '../models/session_models.dart';

/// A card displaying a rest item with timer functionality
class RestItemCard extends HookWidget {
  final SessionRestItemModel restItem;
  final VoidCallback onComplete;
  final VoidCallback onSkip;

  const RestItemCard({
    super.key,
    required this.restItem,
    required this.onComplete,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final isTimerRunning = useState(false);
    final timeRemaining = useState(restItem.restDurationSeconds);

    // Timer effect
    useEffect(() {
      if (!isTimerRunning.value) return null;

      final timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (timeRemaining.value <= 1) {
          isTimerRunning.value = false;
          onComplete();
        } else {
          timeRemaining.value = timeRemaining.value - 1;
        }
      });

      return timer.cancel;
    }, [isTimerRunning.value]);

    // Reset timer when rest item changes
    useEffect(() {
      timeRemaining.value = restItem.restDurationSeconds;
      isTimerRunning.value = false;
      return null;
    }, [restItem.id]);

    if (restItem.isCompleted) {
      // Completed state - compact view
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.bgCard.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.accentGreen.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.accentGreen.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.check,
                color: AppColors.accentGreen,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Rest (${formatDuration(restItem.restDurationSeconds)})',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textMuted,
                decoration: TextDecoration.lineThrough,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: onSkip, // Use skip to toggle back to incomplete
              child: const Icon(
                Icons.undo,
                color: AppColors.textMuted,
                size: 18,
              ),
            ),
          ],
        ),
      );
    }

    // Active/pending state
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isTimerRunning.value
              ? AppColors.accentGreen
              : AppColors.borderColor,
          width: isTimerRunning.value ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.timer_outlined,
                  color: AppColors.accentGreen,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rest',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isTimerRunning.value
                          ? 'Time remaining'
                          : formatDuration(restItem.restDurationSeconds),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isTimerRunning.value)
                Text(
                  formatDuration(timeRemaining.value),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accentGreen,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    onSkip();
                    isTimerRunning.value = false;
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.bgCardInner,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (isTimerRunning.value) {
                      // Stop timer and complete
                      isTimerRunning.value = false;
                      onComplete();
                    } else {
                      // Start timer
                      isTimerRunning.value = true;
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.accentGreen,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        isTimerRunning.value ? 'Done' : 'Start Timer',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
