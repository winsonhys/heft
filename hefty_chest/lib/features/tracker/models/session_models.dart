import 'package:fixnum/fixnum.dart' show Int64;
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../gen/common.pbenum.dart';
import '../../../gen/session.pb.dart';
import '../../../gen/google/protobuf/timestamp.pb.dart';

part 'session_models.freezed.dart';

/// Immutable session model for state management
@freezed
sealed class SessionModel with _$SessionModel {
  const factory SessionModel({
    required String id,
    required String workoutTemplateId,
    required String name,
    required List<SessionExerciseModel> exercises,
    @Default(0) int completedSets,
    @Default(0) int totalSets,
    @Default(0) int durationSeconds,
    DateTime? startedAt,
    DateTime? completedAt,
    @Default('') String notes,
  }) = _SessionModel;

  /// Convert from protobuf Session
  factory SessionModel.fromProto(Session pb) {
    final exercises = pb.exercises.map(SessionExerciseModel.fromProto).toList();

    // Always compute totalSets from exercises (don't rely on stored value)
    final totalSets = exercises.fold(0, (sum, ex) => sum + ex.sets.length);

    return SessionModel(
      id: pb.id,
      workoutTemplateId: pb.workoutTemplateId,
      name: pb.name,
      exercises: exercises,
      completedSets: pb.completedSets,
      totalSets: totalSets,
      durationSeconds: pb.durationSeconds,
      startedAt: pb.hasStartedAt() ? pb.startedAt.toDateTime() : null,
      completedAt: pb.hasCompletedAt() ? pb.completedAt.toDateTime() : null,
      notes: pb.notes,
    );
  }
}

/// Immutable session exercise model
@freezed
sealed class SessionExerciseModel with _$SessionExerciseModel {
  const factory SessionExerciseModel({
    required String id,
    required String exerciseId,
    required String exerciseName,
    required String sectionName,
    required List<SessionSetModel> sets,
    @Default(ExerciseType.EXERCISE_TYPE_UNSPECIFIED) ExerciseType exerciseType,
    @Default(0) int displayOrder,
    @Default('') String notes,
    String? supersetId, // Exercises with same ID are in same superset
  }) = _SessionExerciseModel;

  /// Convert from protobuf SessionExercise
  factory SessionExerciseModel.fromProto(SessionExercise pb) =>
      SessionExerciseModel(
        id: pb.id,
        exerciseId: pb.exerciseId,
        exerciseName: pb.exerciseName,
        sectionName: pb.sectionName,
        sets: pb.sets.map(SessionSetModel.fromProto).toList(),
        exerciseType: pb.exerciseType,
        displayOrder: pb.displayOrder,
        notes: pb.notes,
        supersetId: pb.hasSupersetId() ? pb.supersetId : null,
      );
}

/// Immutable session set model
@freezed
sealed class SessionSetModel with _$SessionSetModel {
  const factory SessionSetModel({
    required String id,
    required int setNumber,
    @Default(0.0) double weightKg,
    @Default(0) int reps,
    @Default(0) int timeSeconds,
    @Default(0.0) double distanceM,
    @Default(false) bool isBodyweight,
    @Default(false) bool isCompleted,
    @Default(0.0) double targetWeightKg,
    @Default(0) int targetReps,
    @Default(0) int targetTimeSeconds,
    @Default(0.0) double rpe,
    @Default('') String notes,
    DateTime? completedAt,
  }) = _SessionSetModel;

  /// Convert from protobuf SessionSet
  factory SessionSetModel.fromProto(SessionSet pb) => SessionSetModel(
        id: pb.id,
        setNumber: pb.setNumber,
        weightKg: pb.weightKg,
        reps: pb.reps,
        timeSeconds: pb.timeSeconds,
        distanceM: pb.distanceM,
        isBodyweight: pb.isBodyweight,
        isCompleted: pb.isCompleted,
        targetWeightKg: pb.targetWeightKg,
        targetReps: pb.targetReps,
        targetTimeSeconds: pb.targetTimeSeconds,
        rpe: pb.rpe,
        notes: pb.notes,
        completedAt: pb.hasCompletedAt() ? pb.completedAt.toDateTime() : null,
      );
}

// Extensions to convert freezed models back to protobuf for storage

extension SessionModelToProto on SessionModel {
  Session toProto() {
    final session = Session()
      ..id = id
      ..workoutTemplateId = workoutTemplateId
      ..name = name
      ..completedSets = completedSets
      ..totalSets = totalSets
      ..durationSeconds = durationSeconds
      ..notes = notes;

    if (startedAt != null) {
      session.startedAt = _dateTimeToTimestamp(startedAt!);
    }
    if (completedAt != null) {
      session.completedAt = _dateTimeToTimestamp(completedAt!);
    }

    session.exercises.addAll(exercises.map((e) => e.toProto()));
    return session;
  }
}

extension SessionExerciseModelToProto on SessionExerciseModel {
  SessionExercise toProto() {
    final exercise = SessionExercise()
      ..id = id
      ..exerciseId = exerciseId
      ..exerciseName = exerciseName
      ..sectionName = sectionName
      ..exerciseType = exerciseType
      ..displayOrder = displayOrder
      ..notes = notes;

    if (supersetId != null) {
      exercise.supersetId = supersetId!;
    }

    exercise.sets.addAll(sets.map((s) => s.toProto()));
    return exercise;
  }
}

extension SessionSetModelToProto on SessionSetModel {
  SessionSet toProto() {
    final set = SessionSet()
      ..id = id
      ..setNumber = setNumber
      ..weightKg = weightKg
      ..reps = reps
      ..timeSeconds = timeSeconds
      ..distanceM = distanceM
      ..isBodyweight = isBodyweight
      ..isCompleted = isCompleted
      ..targetWeightKg = targetWeightKg
      ..targetReps = targetReps
      ..targetTimeSeconds = targetTimeSeconds
      ..rpe = rpe
      ..notes = notes;

    if (completedAt != null) {
      set.completedAt = _dateTimeToTimestamp(completedAt!);
    }

    return set;
  }
}

Timestamp _dateTimeToTimestamp(DateTime dt) {
  final millis = dt.millisecondsSinceEpoch;
  return Timestamp()
    ..seconds = Int64(millis ~/ 1000)
    ..nanos = (millis % 1000) * 1000000;
}
