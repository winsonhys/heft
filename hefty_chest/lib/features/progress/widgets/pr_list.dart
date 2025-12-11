import 'package:flutter/material.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../core/client.dart';
import 'pr_card.dart';

/// List of personal records
class PrList extends StatelessWidget {
  final List<PersonalRecord> records;
  final bool isLoading;

  const PrList({
    super.key,
    required this.records,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: AppColors.accentBlue,
          ),
        ),
      );
    }

    if (records.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.emoji_events_outlined,
                size: 40,
                color: AppColors.textMuted,
              ),
              const SizedBox(height: 8),
              Text(
                'No personal records yet',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Complete workouts to set PRs!',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: records.map((record) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: PrCard(record: record),
        );
      }).toList(),
    );
  }
}
