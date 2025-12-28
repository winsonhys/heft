import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/client.dart';
import '../../../core/logging.dart';

part 'home_providers.g.dart';

/// Provider for the list of workouts
@riverpod
Future<List<WorkoutSummary>> workoutList(Ref ref) async {
  logHome.fine('Fetching workout list');
  final request = ListWorkoutsRequest();
  final response = await workoutClient.listWorkouts(request);
  logHome.fine('Fetched ${response.workouts.length} workouts');
  return response.workouts;
}

/// Provider for dashboard statistics
@riverpod
Future<DashboardStats> dashboardStats(Ref ref) async {
  logHome.fine('Fetching dashboard stats');
  final request = GetDashboardStatsRequest();
  final response = await progressClient.getDashboardStats(request);
  logHome.fine('Dashboard stats fetched');
  return response.stats;
}

/// Provider for a single workout detail
@riverpod
Future<Workout> workoutDetail(Ref ref, String workoutId) async {
  final request = GetWorkoutRequest()..id = workoutId;
  final response = await workoutClient.getWorkout(request);
  return response.workout;
}

/// Delete a workout by ID
Future<void> deleteWorkout(String workoutId) async {
  logHome.info('Deleting workout: $workoutId');
  final request = DeleteWorkoutRequest()..id = workoutId;
  await workoutClient.deleteWorkout(request);
}
