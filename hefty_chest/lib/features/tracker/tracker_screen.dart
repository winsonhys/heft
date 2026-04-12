import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/theme/app_colors.dart';
import '../../shared/utils/formatters.dart';
import '../../shared/widgets/confirm_dialog.dart';
import '../../shared/widgets/floating_session_widget.dart';
import 'providers/session_providers.dart';
import 'widgets/rest_timer_sheet.dart';
import 'widgets/tracker_section_list.dart';

/// Tracker screen for active workout session
class TrackerScreen extends HookConsumerWidget {
  final String? workoutTemplateId;
  final String? sessionId;

  const TrackerScreen({
    super.key,
    this.workoutTemplateId,
    this.sessionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(true);
    final showRestTimer = useState(false);
    final restTimeRemaining = useState(120);
    final nextExerciseName = useState('');
    final nextSetNumber = useState(1);
    final elapsedSeconds = useState(0);
    final isDragging = useState(false);

    final sessionAsync = ref.watch(activeSessionProvider);

    // Timer effect for elapsed time
    useEffect(() {
      final session = sessionAsync.value;
      if (session == null || session.startedAt == null) {
        return null;
      }

      final startedAt = session.startedAt!;
      elapsedSeconds.value = DateTime.now().difference(startedAt).inSeconds;

      final timer = Timer.periodic(const Duration(seconds: 1), (_) {
        elapsedSeconds.value = DateTime.now().difference(startedAt).inSeconds;
      });

      return timer.cancel;
    }, [sessionAsync.value?.id]);

    // Hide floating widget when on tracker screen, show when leaving
    final floatingNotifier = ref.read(floatingWidgetVisibleProvider.notifier);
    useEffect(() {
      Future.microtask(() {
        floatingNotifier.hide();
      });
      return () {
        Future.microtask(() {
          floatingNotifier.show();
        });
      };
    }, [floatingNotifier]);

    // Function to initialize/retry session
    Future<void> initSession() async {
      isLoading.value = true;
      final notifier = ref.read(activeSessionProvider.notifier);

      if (sessionId != null) {
        await notifier.loadSession(sessionId: sessionId!);
      } else if (workoutTemplateId != null) {
        await notifier.startSession(workoutTemplateId: workoutTemplateId!);
      } else {
        await notifier.startSession(name: 'Quick Workout');
      }

      if (context.mounted) {
        isLoading.value = false;
      }
    }

    // Initialize session on mount
    useEffect(() {
      Future.microtask(() => initSession());
      return null;
    }, [sessionId, workoutTemplateId]);

    void hideRestTimer() {
      showRestTimer.value = false;
    }

    Future<void> finishWorkout() async {
      final confirm = await showConfirmDialog(
        context: context,
        title: 'Finish Workout?',
        message: 'Are you sure you want to finish this workout?',
        confirmLabel: 'Finish',
      );

      if (confirm && context.mounted) {
        await ref.read(activeSessionProvider.notifier).finishSession();
        if (context.mounted) {
          context.go('/');
        }
      }
    }

    Future<void> discardWorkout() async {
      final confirm = await showConfirmDialog(
        context: context,
        title: 'Discard Workout?',
        message: 'Are you sure you want to discard this workout? All progress will be lost.',
        confirmLabel: 'Discard',
        isDestructive: true,
      );

      if (confirm && context.mounted) {
        await ref.read(activeSessionProvider.notifier).abandonSession();
        if (context.mounted) {
          context.go('/');
        }
      }
    }

    Future<void> goBackHome() async {
      await ref.read(activeSessionProvider.notifier).cleanup();
      if (context.mounted) {
        context.go('/');
      }
    }

    return Stack(
      children: [
        FScaffold(
          header: FHeader.nested(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  sessionAsync.value?.name.isNotEmpty == true
                      ? sessionAsync.value!.name
                      : 'Workout',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (sessionAsync.value != null) ...[
                  const SizedBox(width: 12),
                  Text(
                    formatDuration(elapsedSeconds.value),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ],
            ),
            prefixes: [
              FHeaderAction.back(key: const Key('tracker_back'), onPress: goBackHome),
            ],
            suffixes: [
              GestureDetector(
                key: const Key('tracker_discard'),
                onTap: discardWorkout,
                child: const Text(
                  'Discard',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.accentRed,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                key: const Key('tracker_finish'),
                onTap: finishWorkout,
                child: const Text(
                  'Finish',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.accentGreen,
                  ),
                ),
              ),
            ],
          ),
          child: isLoading.value
              ? const Center(child: FCircularProgress.loader())
              : sessionAsync.when(
                  data: (session) {
                    if (session == null) {
                      return _buildNoSession(context);
                    }
                    return TrackerSectionList(
                      session: session,
                      isDragging: isDragging,
                      onTriggerRestTimer: (int duration, String exerciseName, int setNumber) {
                        restTimeRemaining.value = duration;
                        nextExerciseName.value = exerciseName;
                        nextSetNumber.value = setNumber;
                        showRestTimer.value = true;
                      },
                    );
                  },
                  loading: () => const Center(child: FCircularProgress.loader()),
                  error: (error, _) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: AppColors.accentRed,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load session, ${error.toString()}',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        FButton(
                          style: FButtonStyle.ghost(),
                          onPress: initSession,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
        ),

        // Manual rest timer floating button
        if (!showRestTimer.value && !isLoading.value && sessionAsync.value != null)
          Positioned(
            bottom: 24,
            right: 16,
            child: GestureDetector(
              key: const Key('manual_rest_timer'),
              onTap: () {
                restTimeRemaining.value = 90;
                nextExerciseName.value = 'Take a breather';
                nextSetNumber.value = 0;
                showRestTimer.value = true;
              },
              child: Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accentBlue,
                ),
                child: const Icon(
                  Icons.timer,
                  color: AppColors.textPrimary,
                  size: 24,
                ),
              ),
            ),
          ),

        // Rest Timer Bottom Sheet
        if (showRestTimer.value)
          RestTimerSheet(
            initialTime: restTimeRemaining.value,
            nextExerciseName: nextExerciseName.value,
            nextSetNumber: nextSetNumber.value,
            onSkip: hideRestTimer,
            onComplete: hideRestTimer,
          ),
      ],
    );
  }

  Widget _buildNoSession(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.fitness_center,
            size: 64,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 16),
          const Text(
            'No active session',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          FButton(
            style: FButtonStyle.ghost(),
            onPress: () => context.go('/'),
            child: const Text('Go back home'),
          ),
        ],
      ),
    );
  }
}
