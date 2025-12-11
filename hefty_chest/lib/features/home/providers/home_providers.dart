import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/client.dart';
import '../../../core/config.dart';

/// Provider for the list of workouts
final workoutListProvider = FutureProvider<List<WorkoutSummary>>((ref) async {
  final request = ListWorkoutsRequest()
    ..userId = AppConfig.hardcodedUserId;

  final response = await workoutClient.listWorkouts(request);
  return response.workouts;
});

/// Provider for dashboard statistics
final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final request = GetDashboardStatsRequest()
    ..userId = AppConfig.hardcodedUserId;

  final response = await progressClient.getDashboardStats(request);
  return response.stats;
});

/// Provider for a single workout detail
final workoutDetailProvider = FutureProvider.family<Workout, String>((ref, workoutId) async {
  final request = GetWorkoutRequest()
    ..id = workoutId
    ..userId = AppConfig.hardcodedUserId;

  final response = await workoutClient.getWorkout(request);
  return response.workout;
});
