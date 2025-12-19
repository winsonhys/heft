import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../shared/theme/app_colors.dart';
import '../../shared/widgets/bottom_nav_bar.dart';
import '../../app/router.dart';
import 'providers/profile_providers.dart';
import 'widgets/stats_grid.dart';
import 'widgets/settings_card.dart';

/// Profile screen displaying user info and settings
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _handleNavTap(BuildContext context, int index) {
    switch (index) {
      case NavIndex.home:
        context.goHome();
        break;
      case NavIndex.progress:
        context.goProgress();
        break;
      case NavIndex.calendar:
        context.goCalendar();
        break;
      case NavIndex.profile:
        // Already on profile
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider);
    final statsAsync = ref.watch(profileStatsProvider);

    return FScaffold(
      header: FHeader.nested(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        prefixes: [
          FHeaderAction.back(onPress: () => context.goHome()),
        ],
      ),
      footer: BottomNavBar(
        selectedIndex: NavIndex.profile,
        onTap: (index) => _handleNavTap(context, index),
      ),
      child: userAsync.when(
        data: (user) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Info
              _buildUserInfo(user.displayName, user.memberSince.toDateTime()),

              const SizedBox(height: 24),

              // Stats Grid
              statsAsync.when(
                data: (stats) => StatsGrid(
                  daysActive: stats.daysActive,
                  totalWorkouts: stats.totalWorkouts,
                  totalVolumeKg: stats.totalVolumeKg,
                ),
                loading: () => const StatsGrid(
                  daysActive: 0,
                  totalWorkouts: 0,
                  totalVolumeKg: 0,
                  isLoading: true,
                ),
                error: (_, _) => const StatsGrid(
                  daysActive: 0,
                  totalWorkouts: 0,
                  totalVolumeKg: 0,
                ),
              ),

              const SizedBox(height: 24),

              // Settings
              const Text(
                'Settings',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              SettingsCard(
                usePounds: user.usePounds,
                restTimerSeconds: user.restTimerSeconds,
                onUnitChanged: (usePounds) {
                  ref.read(userSettingsProvider.notifier).updateSettings(
                        usePounds: usePounds,
                      );
                },
                onRestTimerChanged: (seconds) {
                  ref.read(userSettingsProvider.notifier).updateSettings(
                        restTimerSeconds: seconds,
                      );
                },
              ),
            ],
          ),
        ),
        loading: () => const Center(
          child: FProgress(),
        ),
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
                'Failed to load profile',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              FButton(
                style: FButtonStyle.ghost(),
                onPress: () => ref.invalidate(userProfileProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo(String displayName, DateTime memberSince) {
    final monthYear = '${_monthName(memberSince.month)} ${memberSince.year}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.accentBlue,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName.isNotEmpty ? displayName : 'User',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Member since $monthYear',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}
