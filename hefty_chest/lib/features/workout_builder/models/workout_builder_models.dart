import '../../../core/client.dart';

/// State for the workout builder
class WorkoutBuilderState {
  final String? id;
  final String name;
  final List<BuilderSection> sections;
  final bool isLoading;
  final String? error;

  const WorkoutBuilderState({
    this.id,
    this.name = '',
    this.sections = const [],
    this.isLoading = false,
    this.error,
  });

  WorkoutBuilderState copyWith({
    String? id,
    String? name,
    List<BuilderSection>? sections,
    bool? isLoading,
    String? error,
  }) {
    return WorkoutBuilderState(
      id: id ?? this.id,
      name: name ?? this.name,
      sections: sections ?? this.sections,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Section in the builder
class BuilderSection {
  final String id;
  final String name;
  final bool isSuperset;
  final List<BuilderItem> items;

  const BuilderSection({
    required this.id,
    this.name = 'Section',
    this.isSuperset = false,
    this.items = const [],
  });

  BuilderSection copyWith({
    String? id,
    String? name,
    bool? isSuperset,
    List<BuilderItem>? items,
  }) {
    return BuilderSection(
      id: id ?? this.id,
      name: name ?? this.name,
      isSuperset: isSuperset ?? this.isSuperset,
      items: items ?? this.items,
    );
  }
}

/// Item in a section (exercise or rest)
class BuilderItem {
  final String id;
  final bool isRest;
  // Exercise fields
  final String? exerciseId;
  final String? exerciseName;
  final ExerciseType exerciseType;
  final List<BuilderSet> sets;
  // Rest fields
  final int restDurationSeconds;

  const BuilderItem({
    required this.id,
    this.isRest = false,
    this.exerciseId,
    this.exerciseName,
    this.exerciseType = ExerciseType.EXERCISE_TYPE_WEIGHT_REPS,
    this.sets = const [],
    this.restDurationSeconds = 60,
  });

  BuilderItem copyWith({
    String? id,
    bool? isRest,
    String? exerciseId,
    String? exerciseName,
    ExerciseType? exerciseType,
    List<BuilderSet>? sets,
    int? restDurationSeconds,
  }) {
    return BuilderItem(
      id: id ?? this.id,
      isRest: isRest ?? this.isRest,
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      exerciseType: exerciseType ?? this.exerciseType,
      sets: sets ?? this.sets,
      restDurationSeconds: restDurationSeconds ?? this.restDurationSeconds,
    );
  }
}

/// Set in an exercise
class BuilderSet {
  final String id;
  final int setNumber;
  final double targetWeightKg;
  final int targetReps;
  final int targetTimeSeconds;
  final bool isBodyweight;
  final int? restDurationSeconds;
  final bool isEdited; // Tracks if user has modified this set

  const BuilderSet({
    required this.id,
    this.setNumber = 1,
    this.targetWeightKg = 0,
    this.targetReps = 10,
    this.targetTimeSeconds = 0,
    this.isBodyweight = false,
    this.restDurationSeconds,
    this.isEdited = false,
  });

  BuilderSet copyWith({
    String? id,
    int? setNumber,
    double? targetWeightKg,
    int? targetReps,
    int? targetTimeSeconds,
    bool? isBodyweight,
    int? restDurationSeconds,
    bool? isEdited,
  }) {
    return BuilderSet(
      id: id ?? this.id,
      setNumber: setNumber ?? this.setNumber,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      targetReps: targetReps ?? this.targetReps,
      targetTimeSeconds: targetTimeSeconds ?? this.targetTimeSeconds,
      isBodyweight: isBodyweight ?? this.isBodyweight,
      restDurationSeconds: restDurationSeconds ?? this.restDurationSeconds,
      isEdited: isEdited ?? this.isEdited,
    );
  }
}
