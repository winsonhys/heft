import 'package:connectrpc/test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hefty_chest/core/client.dart';
import 'package:hefty_chest/features/progress/providers/progress_providers.dart';
import 'package:hefty_chest/gen/progress.connect.spec.dart' as progress_specs;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Progress Provider - Mock Tests', () {
    test('gets dashboard stats via provider', () async {
      final mockStats = DashboardStats()
        ..totalWorkouts = 42
        ..workoutsThisWeek = 3
        ..currentStreak = 5;

      final container = ProviderContainer(overrides: [
        progressStatsProvider.overrideWith((ref) async => mockStats),
      ]);

      final stats = await container.read(progressStatsProvider.future);

      expect(stats, isNotNull);
      expect(stats.totalWorkouts, equals(42));

      container.dispose();
    });

    test('gets weekly activity via provider', () async {
      final mockDays = List.generate(
        7,
        (i) => WeeklyActivityDay()
          ..dayOfWeek =
              ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][i]
          ..workoutCount = i % 2,
      );

      final container = ProviderContainer(overrides: [
        weeklyActivityProvider.overrideWith((ref) async => mockDays),
      ]);

      final days = await container.read(weeklyActivityProvider.future);

      expect(days, hasLength(7));

      container.dispose();
    });

    test('gets personal records via provider', () async {
      final container = ProviderContainer(overrides: [
        personalRecordsProvider
            .overrideWith((ref) async => <PersonalRecord>[]),
      ]);

      final records =
          await container.read(personalRecordsProvider.future);

      expect(records, isA<List>());

      container.dispose();
    });

    test('gets exercise progress via provider', () async {
      final mockProgress = ExerciseProgressSummary();

      final container = ProviderContainer(overrides: [
        exerciseProgressProvider.overrideWith(
          (ref, exerciseId) async => mockProgress,
        ),
      ]);

      final progress = await container.read(
        exerciseProgressProvider('ex-1').future,
      );

      expect(progress, isA<ExerciseProgressSummary?>());

      container.dispose();
    });

    test('selected exercise progress workflow', () async {
      final mockProgress = ExerciseProgressSummary();

      final container = ProviderContainer(overrides: [
        exerciseProgressProvider.overrideWith(
          (ref, exerciseId) async => mockProgress,
        ),
      ]);

      // Initially no selection
      expect(container.read(selectedExerciseIdProvider), isNull);

      // Select exercise
      container
          .read(selectedExerciseIdProvider.notifier)
          .selectExercise('ex-1');
      expect(
          container.read(selectedExerciseIdProvider), equals('ex-1'));

      // Get current progress
      final progress = await container.read(
        currentExerciseProgressProvider.future,
      );
      expect(progress, isA<ExerciseProgressSummary?>());

      // Clear selection
      container
          .read(selectedExerciseIdProvider.notifier)
          .clearSelection();
      expect(container.read(selectedExerciseIdProvider), isNull);

      container.dispose();
    });
  });

  group('Progress Provider - Contract Tests', () {
    late ProviderContainer container;

    setUp(() {
      // Start with 5 workouts, incremented after finish
      var totalWorkouts = 5;

      final transport = (FakeTransportBuilder()
            ..unary(progress_specs.ProgressService.getDashboardStats,
                (req, ctx) {
              return GetDashboardStatsResponse()
                ..stats = (DashboardStats()
                  ..totalWorkouts = totalWorkouts
                  ..workoutsThisWeek = 1
                  ..currentStreak = 1);
            }))
          .build();

      useTestTransport(transport);
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
      resetTransport();
    });

    test('progress stats are fetched via provider through transport', () async {
      final stats = await container.read(progressStatsProvider.future);

      expect(stats, isNotNull);
      expect(stats.totalWorkouts, equals(5));
      expect(stats.workoutsThisWeek, equals(1));
      expect(stats.currentStreak, equals(1));
    });
  });
}
