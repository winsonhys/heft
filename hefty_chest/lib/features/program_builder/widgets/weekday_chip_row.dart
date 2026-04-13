import 'package:flutter/material.dart';

import '../../../shared/theme/app_colors.dart';

/// Row of 7 toggleable Mon–Sun chips. ISO weekdays (Mon=1..Sun=7).
class WeekdayChipRow extends StatelessWidget {
  final Set<int> selected;
  final ValueChanged<Set<int>>? onChanged;
  final bool readOnly;

  const WeekdayChipRow({
    super.key,
    required this.selected,
    this.onChanged,
    this.readOnly = false,
  });

  static const _labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  static const _names = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(7, (i) {
        final iso = i + 1;
        final isOn = selected.contains(iso);
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: GestureDetector(
              key: Key('workout_schedule_weekday_${_names[i]}'),
              onTap: readOnly
                  ? null
                  : () {
                      final next = {...selected};
                      if (isOn) {
                        next.remove(iso);
                      } else {
                        next.add(iso);
                      }
                      onChanged?.call(next);
                    },
              child: Container(
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isOn ? AppColors.accentBlue : AppColors.bgCard,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isOn ? AppColors.accentBlue : AppColors.borderColor,
                  ),
                ),
                child: Text(
                  _labels[i],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isOn ? AppColors.textPrimary : AppColors.textMuted,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
