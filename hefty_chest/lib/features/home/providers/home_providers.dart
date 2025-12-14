import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/client.dart';

part 'home_providers.g.dart';

/// Provider for the list of workouts
@riverpod
Future<List<WorkoutSummary>> workoutList(Ref ref) async {
  final request = ListWorkoutsRequest();
  final response = await workoutClient.listWorkouts(request);
  return response.workouts;
}

/// Provider for dashboard statistics
@riverpod
Future<DashboardStats> dashboardStats(Ref ref) async {
  final request = GetDashboardStatsRequest();
  final response = await progressClient.getDashboardStats(request);
  return response.stats;
}

/// Provider for a single workout detail
@riverpod
Future<Workout> workoutDetail(Ref ref, String workoutId) async {
  final request = GetWorkoutRequest()..id = workoutId;
  final response = await workoutClient.getWorkout(request);
  return response.workout;
}
