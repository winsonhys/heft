import 'package:flutter/material.dart';

import '../../../shared/theme/app_colors.dart';

/// Settings card with unit toggle and rest timer stepper
class SettingsCard extends StatelessWidget {
  final bool usePounds;
  final int restTimerSeconds;
  final ValueChanged<bool> onUnitChanged;
  final ValueChanged<int> onRestTimerChanged;

  const SettingsCard({
    super.key,
    required this.usePounds,
    required this.restTimerSeconds,
    required this.onUnitChanged,
    required this.onRestTimerChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          // Unit Toggle
          _SettingsRow(
            icon: Icons.straighten,
            label: 'Weight Unit',
            child: _UnitToggle(
              usePounds: usePounds,
              onChanged: onUnitChanged,
            ),
          ),

          const Divider(
            color: AppColors.borderColor,
            height: 1,
            indent: 16,
            endIndent: 16,
          ),

          // Rest Timer
          _SettingsRow(
            icon: Icons.timer_outlined,
            label: 'Rest Timer',
            child: _TimerStepper(
              seconds: restTimerSeconds,
              onChanged: onRestTimerChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget child;

  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.bgCardInner,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _UnitToggle extends StatelessWidget {
  final bool usePounds;
  final ValueChanged<bool> onChanged;

  const _UnitToggle({
    required this.usePounds,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCardInner,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleOption(
            label: 'KG',
            isSelected: !usePounds,
            onTap: () => onChanged(false),
          ),
          _ToggleOption(
            label: 'LBS',
            isSelected: usePounds,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

class _TimerStepper extends StatelessWidget {
  final int seconds;
  final ValueChanged<int> onChanged;

  const _TimerStepper({
    required this.seconds,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCardInner,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperButton(
            icon: Icons.remove,
            onTap: () {
              if (seconds > 30) {
                onChanged(seconds - 30);
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              _formatDuration(seconds),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          _StepperButton(
            icon: Icons.add,
            onTap: () {
              if (seconds < 300) {
                onChanged(seconds + 30);
              }
            },
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    if (minutes > 0) {
      return secs > 0 ? '${minutes}m ${secs}s' : '${minutes}m';
    }
    return '${secs}s';
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StepperButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          size: 18,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
