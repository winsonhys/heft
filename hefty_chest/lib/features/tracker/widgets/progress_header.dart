import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../shared/theme/app_colors.dart';
import '../providers/session_providers.dart';

/// Progress header showing workout completion percentage and sync status
class ProgressHeader extends HookConsumerWidget {
  const ProgressHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(activeSessionProvider).value;

    final syncStatus = useState(SyncStatus.synced);
    useEffect(() {
      final timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
        final notifier = ref.read(activeSessionProvider.notifier);
        final current = notifier.syncStatus;
        if (syncStatus.value != current) {
          syncStatus.value = current;
        }
      });
      return timer.cancel;
    }, const []);

    if (session == null) return const SizedBox.shrink();

    final totalSets = session.totalSets;
    final completedSets = session.completedSets;
    final progress = totalSets > 0 ? completedSets / totalSets : 0.0;
    final percentage = (progress * 100).toInt();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progress',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$completedSets / $totalSets sets',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  _SyncIndicator(status: syncStatus.value),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar with animation
          FDeterminateProgress(
            value: progress.clamp(0.0, 1.0),
            style: (style) => style.copyWith(
              constraints: const BoxConstraints.tightFor(height: 8),
              trackDecoration: BoxDecoration(
                color: AppColors.bgCardInner,
                borderRadius: BorderRadius.circular(4),
              ),
              fillDecoration: BoxDecoration(
                color: AppColors.accentGreen,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$percentage% complete',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _SyncIndicator extends StatelessWidget {
  const _SyncIndicator({required this.status});

  final SyncStatus status;

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      SyncStatus.syncing => const SizedBox(
          width: 10,
          height: 10,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.textSecondary,
          ),
        ),
      _ => Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: switch (status) {
              SyncStatus.synced => AppColors.accentGreen,
              SyncStatus.pending => AppColors.accentOrange,
              SyncStatus.error => AppColors.accentRed,
              SyncStatus.syncing => AppColors.textSecondary, // unreachable
            },
          ),
        ),
    };
  }
}
