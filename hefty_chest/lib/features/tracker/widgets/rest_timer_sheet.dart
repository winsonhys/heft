import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';

import '../../../shared/theme/app_colors.dart';

/// Rest timer bottom sheet with circular progress
class RestTimerSheet extends HookWidget {
  final int initialTime;
  final String nextExerciseName;
  final int nextSetNumber;
  final VoidCallback onSkip;
  final VoidCallback onComplete;

  const RestTimerSheet({
    super.key,
    required this.initialTime,
    required this.nextExerciseName,
    required this.nextSetNumber,
    required this.onSkip,
    required this.onComplete,
  });

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }

  Color _getProgressColor(int timeRemaining) {
    if (timeRemaining <= 10) {
      return AppColors.accentGreen;
    } else if (timeRemaining <= 30) {
      return AppColors.accentOrange;
    }
    return AppColors.accentBlue;
  }

  Color _getTextColor(int timeRemaining) {
    if (timeRemaining <= 10) {
      return AppColors.accentGreen;
    } else if (timeRemaining <= 30) {
      return AppColors.accentOrange;
    }
    return AppColors.textPrimary;
  }

  @override
  Widget build(BuildContext context) {
    final timeRemaining = useState(initialTime);
    final totalDuration = useState(initialTime);

    // Timer effect with cleanup
    useEffect(() {
      final timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (timeRemaining.value <= 0) {
          timer.cancel();
          onComplete();
        } else {
          timeRemaining.value--;
        }
      });
      return () => timer.cancel();
    }, []);

    void addTime() {
      timeRemaining.value += 30;
      totalDuration.value += 30;
    }

    final progress = timeRemaining.value / totalDuration.value;
    final progressColor = _getProgressColor(timeRemaining.value);
    final textColor = _getTextColor(timeRemaining.value);

    return Positioned(
      left: 12,
      right: 12,
      bottom: 80,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Circular timer
            SizedBox(
              width: 56,
              height: 56,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background circle
                  CustomPaint(
                    size: const Size(56, 56),
                    painter: _CircleProgressPainter(
                      progress: progress,
                      progressColor: progressColor,
                      backgroundColor: AppColors.bgCardInner,
                      strokeWidth: 4,
                    ),
                  ),
                  // Time text
                  Text(
                    _formatTime(timeRemaining.value),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Rest',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Next: $nextExerciseName - Set $nextSetNumber',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FButton(
                  style: FButtonStyle.ghost(),
                  onPress: onSkip,
                  child: const Text('Skip'),
                ),
                const SizedBox(width: 8),
                FButton(
                  onPress: addTime,
                  child: const Text('+30s'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for circular progress
class _CircleProgressPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color backgroundColor;
  final double strokeWidth;

  _CircleProgressPainter({
    required this.progress,
    required this.progressColor,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_CircleProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor;
  }
}
