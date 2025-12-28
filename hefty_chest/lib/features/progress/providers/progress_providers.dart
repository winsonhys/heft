import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/client.dart';
import '../../../core/logging.dart';

part 'progress_providers.g.dart';

/// Provider for dashboard stats
@riverpod
Future<DashboardStats> progressStats(Ref ref) async {
  logProgress.fine('Fetching dashboard stats');
  final request = GetDashboardStatsRequest();

  final response = await progressClient.getDashboardStats(request);
  logProgress.fine('Dashboard stats fetched');
  return response.stats;
}

/// Provider for weekly activity data
@riverpod
Future<List<WeeklyActivityDay>> weeklyActivity(Ref ref) async {
  logProgress.fine('Fetching weekly activity data');
  final request = GetWeeklyActivityRequest();

  final response = await progressClient.getWeeklyActivity(request);
  logProgress.fine('Fetched ${response.days.length} weekly activity days');
  return response.days;
}

/// Provider for personal records (limit to 5 recent)
@riverpod
Future<List<PersonalRecord>> personalRecords(Ref ref) async {
  logProgress.fine('Fetching personal records');
  final request = GetPersonalRecordsRequest()..limit = 5;

  final response = await progressClient.getPersonalRecords(request);
  logProgress.fine('Fetched ${response.records.length} personal records');
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

  logProgress.fine('Fetching exercise progress for $exerciseId');
  final request = GetExerciseProgressRequest()
    ..exerciseId = exerciseId
    ..limit = 20;

  final response = await progressClient.getExerciseProgress(request);
  logProgress.fine('Exercise progress fetched for $exerciseId');
  return response.progress;
}

/// Provider for list of exercises (for exercise selector)
@riverpod
Future<List<Exercise>> exercisesList(Ref ref) async {
  logProgress.fine('Fetching exercises list');
  final request = ListExercisesRequest();
  final response = await exerciseClient.listExercises(request);
  logProgress.fine('Fetched ${response.exercises.length} exercises');
  return response.exercises;
}

/// Computed provider for current exercise progress based on selected exercise
@riverpod
Future<ExerciseProgressSummary?> currentExerciseProgress(Ref ref) async {
  final selectedId = ref.watch(selectedExerciseIdProvider);
  if (selectedId == null) return null;

  return ref.watch(exerciseProgressProvider(selectedId).future);
}
