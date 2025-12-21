import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../shared/theme/app_colors.dart';
import '../../shared/utils/formatters.dart';
import '../tracker/models/session_models.dart';
import 'providers/history_providers.dart';
import 'widgets/history_exercise_card.dart';

/// Screen showing full details of a completed session
class SessionDetailScreen extends ConsumerWidget {
  final String sessionId;

  const SessionDetailScreen({
    super.key,
    required this.sessionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(sessionDetailProvider(sessionId));

    return sessionAsync.when(
      loading: () => FScaffold(
        header: FHeader.nested(
          title: const Text('Loading...'),
          prefixes: [
            FHeaderAction.back(onPress: () => context.pop()),
          ],
        ),
        child: const Center(
          child: FCircularProgress.loader(),
        ),
      ),
      error: (error, _) => FScaffold(
        header: FHeader.nested(
          title: const Text('Error'),
          prefixes: [
            FHeaderAction.back(onPress: () => context.pop()),
          ],
        ),
        child: Center(
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
                'Failed to load session',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              FButton(
                style: FButtonStyle.ghost(),
                onPress: () =>
                    ref.invalidate(sessionDetailProvider(sessionId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (session) => _buildContent(context, session),
    );
  }

  Widget _buildContent(BuildContext context, SessionModel session) {
    final completedAt = session.completedAt?.toLocal();
    final dateStr = completedAt != null
        ? DateFormat('MMM d, yyyy').format(completedAt)
        : 'In progress';
    final completionPercent = session.totalSets > 0
        ? ((session.completedSets / session.totalSets) * 100).round()
        : 0;

    // Group exercises by section
    final exercisesBySection = <String, List<SessionExerciseModel>>{};
    for (final exercise in session.exercises) {
      final sectionName =
          exercise.sectionName.isEmpty ? 'Exercises' : exercise.sectionName;
      exercisesBySection.putIfAbsent(sectionName, () => []).add(exercise);
    }

    return FScaffold(
      header: FHeader.nested(
        title: Text(
          session.name.isNotEmpty ? session.name : 'Workout',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        prefixes: [
          FHeaderAction.back(onPress: () => context.pop()),
        ],
      ),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Session summary card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  Icons.calendar_today,
                  dateStr,
                  'Date',
                ),
                _buildStatItem(
                  Icons.timer,
                  formatDuration(session.durationSeconds),
                  'Duration',
                ),
                _buildStatItem(
                  Icons.check_circle,
                  '$completionPercent%',
                  'Complete',
                  color: completionPercent >= 80
                      ? AppColors.accentGreen
                      : completionPercent >= 50
                          ? AppColors.accentOrange
                          : AppColors.textSecondary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Exercises by section
          ...exercisesBySection.entries.expand((entry) => [
                // Section header
                Padding(
                  key: ValueKey('section-header-${entry.key}'),
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    entry.key,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                // Exercises
                ...entry.value.map((exercise) => HistoryExerciseCard(
                      key: ValueKey('exercise-${exercise.id}'),
                      exercise: exercise,
                    )),
                SizedBox(key: ValueKey('spacer-${entry.key}'), height: 12),
              ]),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String value,
    String label, {
    Color? color,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: color ?? AppColors.textSecondary,
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: color ?? AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
