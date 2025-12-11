import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/client.dart';
import '../../../core/config.dart';

/// Provider for dashboard stats
final progressStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final request = GetDashboardStatsRequest()
    ..userId = AppConfig.hardcodedUserId;

  final response = await progressClient.getDashboardStats(request);
  return response.stats;
});

/// Provider for weekly activity data
final weeklyActivityProvider =
    FutureProvider<List<WeeklyActivityDay>>((ref) async {
  final request = GetWeeklyActivityRequest()
    ..userId = AppConfig.hardcodedUserId;

  final response = await progressClient.getWeeklyActivity(request);
  return response.days;
});

/// Provider for personal records (limit to 5 recent)
final personalRecordsProvider =
    FutureProvider<List<PersonalRecord>>((ref) async {
  final request = GetPersonalRecordsRequest()
    ..userId = AppConfig.hardcodedUserId
    ..limit = 5;

  final response = await progressClient.getPersonalRecords(request);
  return response.records;
});

/// Notifier for selected exercise ID for progress chart
class SelectedExerciseIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void selectExercise(String? exerciseId) => state = exerciseId;

  void clearSelection() => state = null;
}

/// Selected exercise ID for progress chart
final selectedExerciseIdProvider =
    NotifierProvider<SelectedExerciseIdNotifier, String?>(
        SelectedExerciseIdNotifier.new);

/// Provider for exercise progress data
final exerciseProgressProvider =
    FutureProvider.family<ExerciseProgressSummary?, String>((ref, exerciseId) async {
  if (exerciseId.isEmpty) return null;

  final request = GetExerciseProgressRequest()
    ..userId = AppConfig.hardcodedUserId
    ..exerciseId = exerciseId
    ..limit = 20;

  final response = await progressClient.getExerciseProgress(request);
  return response.progress;
});

/// Provider for list of exercises (for exercise selector)
final exercisesListProvider = FutureProvider<List<Exercise>>((ref) async {
  final request = ListExercisesRequest();
  final response = await exerciseClient.listExercises(request);
  return response.exercises;
});

/// Computed provider for current exercise progress based on selected exercise
final currentExerciseProgressProvider =
    FutureProvider<ExerciseProgressSummary?>((ref) async {
  final selectedId = ref.watch(selectedExerciseIdProvider);
  if (selectedId == null) return null;

  return ref.watch(exerciseProgressProvider(selectedId).future);
});
