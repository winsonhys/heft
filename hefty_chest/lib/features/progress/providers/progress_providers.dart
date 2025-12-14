import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/client.dart';

part 'progress_providers.g.dart';

/// Provider for dashboard stats
@riverpod
Future<DashboardStats> progressStats(Ref ref) async {
  final request = GetDashboardStatsRequest();

  final response = await progressClient.getDashboardStats(request);
  return response.stats;
}

/// Provider for weekly activity data
@riverpod
Future<List<WeeklyActivityDay>> weeklyActivity(Ref ref) async {
  final request = GetWeeklyActivityRequest();

  final response = await progressClient.getWeeklyActivity(request);
  return response.days;
}

/// Provider for personal records (limit to 5 recent)
@riverpod
Future<List<PersonalRecord>> personalRecords(Ref ref) async {
  final request = GetPersonalRecordsRequest()..limit = 5;

  final response = await progressClient.getPersonalRecords(request);
  return response.records;
}

/// Notifier for selected exercise ID for progress chart
@riverpod
class SelectedExerciseId extends _$SelectedExerciseId {
  @override
  String? build() => null;

  void selectExercise(String? exerciseId) => state = exerciseId;

  void clearSelection() => state = null;
}

/// Provider for exercise progress data
@riverpod
Future<ExerciseProgressSummary?> exerciseProgress(
    Ref ref, String exerciseId) async {
  if (exerciseId.isEmpty) return null;

  final request = GetExerciseProgressRequest()
    ..exerciseId = exerciseId
    ..limit = 20;

  final response = await progressClient.getExerciseProgress(request);
  return response.progress;
}

/// Provider for list of exercises (for exercise selector)
@riverpod
Future<List<Exercise>> exercisesList(Ref ref) async {
  final request = ListExercisesRequest();
  final response = await exerciseClient.listExercises(request);
  return response.exercises;
}

/// Computed provider for current exercise progress based on selected exercise
@riverpod
Future<ExerciseProgressSummary?> currentExerciseProgress(Ref ref) async {
  final selectedId = ref.watch(selectedExerciseIdProvider);
  if (selectedId == null) return null;

  return ref.watch(exerciseProgressProvider(selectedId).future);
}
