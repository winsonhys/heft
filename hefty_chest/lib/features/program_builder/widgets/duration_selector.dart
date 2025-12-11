import 'package:flutter/material.dart';

import '../../../shared/theme/app_colors.dart';

/// Widget for selecting program duration
class DurationSelector extends StatelessWidget {
  final int weeks;
  final int days;
  final Function(int weeks, int days) onChanged;

  const DurationSelector({
    super.key,
    required this.weeks,
    required this.days,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Weeks and days inputs
        Row(
          children: [
            // Weeks
            Expanded(
              child: _DurationInput(
                label: 'Weeks',
                value: weeks,
                onDecrement: () => onChanged((weeks - 1).clamp(1, 52), days),
                onIncrement: () => onChanged((weeks + 1).clamp(1, 52), days),
              ),
            ),
            const SizedBox(width: 16),
            // Days
            Expanded(
              child: _DurationInput(
                label: 'Days',
                value: days,
                onDecrement: () => onChanged(weeks, (days - 1).clamp(0, 6)),
                onIncrement: () => onChanged(weeks, (days + 1).clamp(0, 6)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Preset buttons
        Row(
          children: [
            _PresetButton(
              label: '4 weeks',
              isSelected: weeks == 4 && days == 0,
              onTap: () => onChanged(4, 0),
            ),
            const SizedBox(width: 8),
            _PresetButton(
              label: '6 weeks',
              isSelected: weeks == 6 && days == 0,
              onTap: () => onChanged(6, 0),
            ),
            const SizedBox(width: 8),
            _PresetButton(
              label: '8 weeks',
              isSelected: weeks == 8 && days == 0,
              onTap: () => onChanged(8, 0),
            ),
            const SizedBox(width: 8),
            _PresetButton(
              label: '12 weeks',
              isSelected: weeks == 12 && days == 0,
              onTap: () => onChanged(12, 0),
            ),
          ],
        ),
      ],
    );
  }
}

class _DurationInput extends StatelessWidget {
  final String label;
  final int value;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _DurationInput({
    required this.label,
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Decrement button
          GestureDetector(
            onTap: onDecrement,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.bgPrimary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.remove,
                size: 18,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          // Value
          Expanded(
            child: Column(
              children: [
                Text(
                  value.toString(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          // Increment button
          GestureDetector(
            onTap: onIncrement,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.bgPrimary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.add,
                size: 18,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PresetButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PresetButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentBlue : AppColors.bgCard,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}
