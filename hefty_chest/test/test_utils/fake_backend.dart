import 'package:connectrpc/connect.dart';
import 'package:connectrpc/test.dart';
import 'package:hefty_chest/core/client.dart';
import 'package:hefty_chest/gen/exercise.connect.spec.dart' as exercise_specs;
import 'package:hefty_chest/gen/program.connect.spec.dart' as program_specs;
import 'package:hefty_chest/gen/session.connect.spec.dart' as session_specs;
import 'package:hefty_chest/gen/workout.connect.spec.dart' as workout_specs;

/// In-memory fake backend for contract tests.
///
/// Provides stateful CRUD handlers using connectrpc's FakeTransportBuilder.
/// All responses use real proto types, enforcing the API contract.
class FakeBackend {
  final Map<String, Workout> _workouts = {};
  final Map<String, Program> _programs = {};
  final Map<String, Session> _sessions = {};
  int _idCounter = 0;

  String _nextId(String prefix) => '$prefix-${++_idCounter}';

  /// Seed exercises available for tests
  final List<Exercise> exercises = [
    Exercise()
      ..id = 'ex-bench'
      ..name = 'Bench Press'
      ..exerciseType = ExerciseType.EXERCISE_TYPE_WEIGHT_REPS,
    Exercise()
      ..id = 'ex-squat'
      ..name = 'Squat'
      ..exerciseType = ExerciseType.EXERCISE_TYPE_WEIGHT_REPS,
    Exercise()
      ..id = 'ex-deadlift'
      ..name = 'Deadlift'
      ..exerciseType = ExerciseType.EXERCISE_TYPE_WEIGHT_REPS,
  ];

  /// Build a Transport with all CRUD handlers registered.
  Transport buildTransport() {
    return (FakeTransportBuilder()
          // Exercise
          ..unary(exercise_specs.ExerciseService.listExercises, _listExercises)
          ..unary(
              exercise_specs.ExerciseService.searchExercises, _searchExercises)
          // Workout
          ..unary(workout_specs.WorkoutService.createWorkout, _createWorkout)
          ..unary(workout_specs.WorkoutService.getWorkout, _getWorkout)
          ..unary(workout_specs.WorkoutService.listWorkouts, _listWorkouts)
          ..unary(workout_specs.WorkoutService.updateWorkout, _updateWorkout)
          ..unary(workout_specs.WorkoutService.deleteWorkout, _deleteWorkout)
          // Program
          ..unary(program_specs.ProgramService.createProgram, _createProgram)
          ..unary(program_specs.ProgramService.getProgram, _getProgram)
          ..unary(program_specs.ProgramService.listPrograms, _listPrograms)
          ..unary(program_specs.ProgramService.updateProgram, _updateProgram)
          ..unary(program_specs.ProgramService.deleteProgram, _deleteProgram)
          // Session (minimal for abandonAnyActiveSession)
          ..unary(session_specs.SessionService.listSessions, _listSessions)
          ..unary(
              session_specs.SessionService.abandonSession, _abandonSession))
        .build();
  }

  // === Exercise handlers ===

  ListExercisesResponse _listExercises(
      ListExercisesRequest req, FakeHandlerContext ctx) {
    return ListExercisesResponse()..exercises.addAll(exercises);
  }

  SearchExercisesResponse _searchExercises(
      SearchExercisesRequest req, FakeHandlerContext ctx) {
    final query = req.query.toLowerCase();
    final matches =
        exercises.where((e) => e.name.toLowerCase().contains(query));
    return SearchExercisesResponse()..exercises.addAll(matches);
  }

  // === Workout handlers ===

  CreateWorkoutResponse _createWorkout(
      CreateWorkoutRequest req, FakeHandlerContext ctx) {
    final id = _nextId('w');
    final workout = Workout()
      ..id = id
      ..name = req.name
      ..description = req.description;

    // Convert sections
    for (final section in req.sections) {
      final ws = WorkoutSection()
        ..id = _nextId('ws')
        ..name = section.name
        ..displayOrder = section.displayOrder
        ..isSuperset = section.isSuperset;

      for (final item in section.items) {
        final si = SectionItem()
          ..id = _nextId('si')
          ..displayOrder = item.displayOrder
          ..itemType = item.itemType;

        if (item.itemType == SectionItemType.SECTION_ITEM_TYPE_EXERCISE) {
          si.exerciseId = item.exerciseId;
          // Look up exercise name
          final exercise = exercises.where((e) => e.id == item.exerciseId);
          if (exercise.isNotEmpty) {
            si.exerciseName = exercise.first.name;
            si.exerciseType = exercise.first.exerciseType;
          }
          for (final ts in item.targetSets) {
            si.targetSets.add(TargetSet()
              ..id = _nextId('ts')
              ..setNumber = ts.setNumber
              ..targetWeightKg = ts.targetWeightKg
              ..targetReps = ts.targetReps);
          }
        } else {
          si.restDurationSeconds = item.restDurationSeconds;
        }

        ws.items.add(si);
      }
      workout.sections.add(ws);
    }

    _workouts[id] = workout;
    return CreateWorkoutResponse()..workout = workout;
  }

  GetWorkoutResponse _getWorkout(
      GetWorkoutRequest req, FakeHandlerContext ctx) {
    final workout = _workouts[req.id];
    if (workout == null) {
      throw ConnectException(Code.notFound, 'workout not found');
    }
    return GetWorkoutResponse()..workout = workout;
  }

  ListWorkoutsResponse _listWorkouts(
      ListWorkoutsRequest req, FakeHandlerContext ctx) {
    final summaries = _workouts.values.map((w) {
      return WorkoutSummary()
        ..id = w.id
        ..name = w.name
        ..description = w.description
        ..totalExercises = w.sections.fold(0, (sum, s) => sum + s.items.length)
        ..totalSets = w.sections.fold(
            0,
            (sum, s) =>
                sum +
                s.items.fold(0,
                    (sum2, i) => sum2 + i.targetSets.length));
    });
    return ListWorkoutsResponse()..workouts.addAll(summaries);
  }

  UpdateWorkoutResponse _updateWorkout(
      UpdateWorkoutRequest req, FakeHandlerContext ctx) {
    final existing = _workouts[req.id];
    if (existing == null) {
      throw ConnectException(Code.notFound, 'workout not found');
    }
    // Update fields
    final updated = Workout()
      ..id = req.id
      ..name = req.name
      ..description = req.description;
    for (final section in req.sections) {
      final ws = WorkoutSection()
        ..id = _nextId('ws')
        ..name = section.name
        ..displayOrder = section.displayOrder
        ..isSuperset = section.isSuperset;
      for (final item in section.items) {
        final si = SectionItem()
          ..id = _nextId('si')
          ..displayOrder = item.displayOrder
          ..itemType = item.itemType;
        if (item.itemType == SectionItemType.SECTION_ITEM_TYPE_EXERCISE) {
          si.exerciseId = item.exerciseId;
          for (final ts in item.targetSets) {
            si.targetSets.add(TargetSet()
              ..id = _nextId('ts')
              ..setNumber = ts.setNumber
              ..targetWeightKg = ts.targetWeightKg
              ..targetReps = ts.targetReps);
          }
        } else {
          si.restDurationSeconds = item.restDurationSeconds;
        }
        ws.items.add(si);
      }
      updated.sections.add(ws);
    }
    _workouts[req.id] = updated;
    return UpdateWorkoutResponse()..workout = updated;
  }

  DeleteWorkoutResponse _deleteWorkout(
      DeleteWorkoutRequest req, FakeHandlerContext ctx) {
    _workouts.remove(req.id);
    return DeleteWorkoutResponse();
  }

  // === Program handlers ===

  CreateProgramResponse _createProgram(
      CreateProgramRequest req, FakeHandlerContext ctx) {
    final id = _nextId('p');
    final program = Program()
      ..id = id
      ..name = req.name
      ..durationWeeks = req.durationWeeks
      ..durationDays = req.durationDays;

    for (final day in req.days) {
      program.days.add(ProgramDay()
        ..id = _nextId('pd')
        ..dayNumber = day.dayNumber
        ..dayType = day.dayType
        ..workoutTemplateId = day.workoutTemplateId);
    }

    _programs[id] = program;
    return CreateProgramResponse()..program = program;
  }

  GetProgramResponse _getProgram(
      GetProgramRequest req, FakeHandlerContext ctx) {
    final program = _programs[req.id];
    if (program == null) {
      throw ConnectException(Code.notFound, 'program not found');
    }
    return GetProgramResponse()..program = program;
  }

  ListProgramsResponse _listPrograms(
      ListProgramsRequest req, FakeHandlerContext ctx) {
    final summaries = _programs.values.map((p) {
      return ProgramSummary()
        ..id = p.id
        ..name = p.name
        ..durationWeeks = p.durationWeeks;
    });
    return ListProgramsResponse()..programs.addAll(summaries);
  }

  UpdateProgramResponse _updateProgram(
      UpdateProgramRequest req, FakeHandlerContext ctx) {
    final updated = Program()
      ..id = req.id
      ..name = req.name
      ..durationWeeks = req.durationWeeks
      ..durationDays = req.durationDays;
    for (final day in req.days) {
      updated.days.add(ProgramDay()
        ..id = _nextId('pd')
        ..dayNumber = day.dayNumber
        ..dayType = day.dayType
        ..workoutTemplateId = day.workoutTemplateId);
    }
    _programs[req.id] = updated;
    return UpdateProgramResponse()..program = updated;
  }

  DeleteProgramResponse _deleteProgram(
      DeleteProgramRequest req, FakeHandlerContext ctx) {
    _programs.remove(req.id);
    return DeleteProgramResponse();
  }

  // === Session handlers (minimal) ===

  ListSessionsResponse _listSessions(
      ListSessionsRequest req, FakeHandlerContext ctx) {
    return ListSessionsResponse(); // No active sessions
  }

  AbandonSessionResponse _abandonSession(
      AbandonSessionRequest req, FakeHandlerContext ctx) {
    _sessions.remove(req.id);
    return AbandonSessionResponse();
  }
}
