import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/client.dart';
import '../../../core/config.dart';

const _uuid = Uuid();

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

  const BuilderSet({
    required this.id,
    this.setNumber = 1,
    this.targetWeightKg = 0,
    this.targetReps = 10,
    this.targetTimeSeconds = 0,
    this.isBodyweight = false,
  });

  BuilderSet copyWith({
    String? id,
    int? setNumber,
    double? targetWeightKg,
    int? targetReps,
    int? targetTimeSeconds,
    bool? isBodyweight,
  }) {
    return BuilderSet(
      id: id ?? this.id,
      setNumber: setNumber ?? this.setNumber,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      targetReps: targetReps ?? this.targetReps,
      targetTimeSeconds: targetTimeSeconds ?? this.targetTimeSeconds,
      isBodyweight: isBodyweight ?? this.isBodyweight,
    );
  }
}

/// Workout builder state notifier
class WorkoutBuilderNotifier extends Notifier<WorkoutBuilderState> {
  @override
  WorkoutBuilderState build() => const WorkoutBuilderState();

  void reset() {
    state = const WorkoutBuilderState();
  }

  Future<void> loadWorkout(String workoutId) async {
    state = state.copyWith(isLoading: true);
    try {
      final request = GetWorkoutRequest()
        ..id = workoutId
        ..userId = AppConfig.hardcodedUserId;

      final response = await workoutClient.getWorkout(request);
      final workout = response.workout;

      // Convert to builder state
      final sections = workout.sections.map((section) {
        final items = section.items.map((item) {
          if (item.itemType == SectionItemType.SECTION_ITEM_TYPE_REST) {
            return BuilderItem(
              id: item.id.isEmpty ? _uuid.v4() : item.id,
              isRest: true,
              restDurationSeconds: item.restDurationSeconds,
            );
          } else {
            return BuilderItem(
              id: item.id.isEmpty ? _uuid.v4() : item.id,
              isRest: false,
              exerciseId: item.exerciseId,
              exerciseName: item.exerciseName,
              exerciseType: item.exerciseType,
              sets: item.targetSets
                  .map((s) => BuilderSet(
                        id: s.id.isEmpty ? _uuid.v4() : s.id,
                        setNumber: s.setNumber,
                        targetWeightKg: s.targetWeightKg,
                        targetReps: s.targetReps,
                        targetTimeSeconds: s.targetTimeSeconds,
                        isBodyweight: s.isBodyweight,
                      ))
                  .toList(),
            );
          }
        }).toList();

        return BuilderSection(
          id: section.id.isEmpty ? _uuid.v4() : section.id,
          name: section.name,
          isSuperset: section.isSuperset,
          items: items,
        );
      }).toList();

      state = state.copyWith(
        id: workout.id,
        name: workout.name,
        sections: sections,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void updateName(String name) {
    state = state.copyWith(name: name);
  }

  void addSection() {
    final newSection = BuilderSection(
      id: _uuid.v4(),
      name: 'Section ${state.sections.length + 1}',
    );
    state = state.copyWith(sections: [...state.sections, newSection]);
  }

  void deleteSection(String sectionId) {
    state = state.copyWith(
      sections: state.sections.where((s) => s.id != sectionId).toList(),
    );
  }

  void toggleSuperset(String sectionId) {
    state = state.copyWith(
      sections: state.sections.map((s) {
        if (s.id == sectionId) {
          return s.copyWith(isSuperset: !s.isSuperset);
        }
        return s;
      }).toList(),
    );
  }

  void addExercise(String sectionId, Exercise exercise) {
    state = state.copyWith(
      sections: state.sections.map((s) {
        if (s.id == sectionId) {
          final newItem = BuilderItem(
            id: _uuid.v4(),
            isRest: false,
            exerciseId: exercise.id,
            exerciseName: exercise.name,
            exerciseType: exercise.exerciseType,
            sets: [
              BuilderSet(id: _uuid.v4(), setNumber: 1),
            ],
          );
          return s.copyWith(items: [...s.items, newItem]);
        }
        return s;
      }).toList(),
    );
  }

  void deleteExercise(String sectionId, String itemId) {
    state = state.copyWith(
      sections: state.sections.map((s) {
        if (s.id == sectionId) {
          return s.copyWith(
            items: s.items.where((i) => i.id != itemId).toList(),
          );
        }
        return s;
      }).toList(),
    );
  }

  void addRest(String sectionId) {
    state = state.copyWith(
      sections: state.sections.map((s) {
        if (s.id == sectionId) {
          final newItem = BuilderItem(
            id: _uuid.v4(),
            isRest: true,
            restDurationSeconds: 60,
          );
          return s.copyWith(items: [...s.items, newItem]);
        }
        return s;
      }).toList(),
    );
  }

  void updateRestDuration(String sectionId, String itemId, int seconds) {
    state = state.copyWith(
      sections: state.sections.map((s) {
        if (s.id == sectionId) {
          return s.copyWith(
            items: s.items.map((i) {
              if (i.id == itemId) {
                return i.copyWith(restDurationSeconds: seconds);
              }
              return i;
            }).toList(),
          );
        }
        return s;
      }).toList(),
    );
  }

  void addSet(String sectionId, String itemId) {
    state = state.copyWith(
      sections: state.sections.map((s) {
        if (s.id == sectionId) {
          return s.copyWith(
            items: s.items.map((i) {
              if (i.id == itemId) {
                final newSet = BuilderSet(
                  id: _uuid.v4(),
                  setNumber: i.sets.length + 1,
                );
                return i.copyWith(sets: [...i.sets, newSet]);
              }
              return i;
            }).toList(),
          );
        }
        return s;
      }).toList(),
    );
  }

  void deleteSet(String sectionId, String itemId, String setId) {
    state = state.copyWith(
      sections: state.sections.map((s) {
        if (s.id == sectionId) {
          return s.copyWith(
            items: s.items.map((i) {
              if (i.id == itemId) {
                final newSets =
                    i.sets.where((set) => set.id != setId).toList();
                // Re-number sets
                for (int idx = 0; idx < newSets.length; idx++) {
                  newSets[idx] = newSets[idx].copyWith(setNumber: idx + 1);
                }
                return i.copyWith(sets: newSets);
              }
              return i;
            }).toList(),
          );
        }
        return s;
      }).toList(),
    );
  }

  void updateSetValues(
    String sectionId,
    String itemId,
    String setId, {
    double? weight,
    int? reps,
    int? time,
    bool? bodyweight,
  }) {
    state = state.copyWith(
      sections: state.sections.map((s) {
        if (s.id == sectionId) {
          return s.copyWith(
            items: s.items.map((i) {
              if (i.id == itemId) {
                return i.copyWith(
                  sets: i.sets.map((set) {
                    if (set.id == setId) {
                      return set.copyWith(
                        targetWeightKg: weight ?? set.targetWeightKg,
                        targetReps: reps ?? set.targetReps,
                        targetTimeSeconds: time ?? set.targetTimeSeconds,
                        isBodyweight: bodyweight ?? set.isBodyweight,
                      );
                    }
                    return set;
                  }).toList(),
                );
              }
              return i;
            }).toList(),
          );
        }
        return s;
      }).toList(),
    );
  }

  Future<bool> saveWorkout() async {
    if (state.name.isEmpty) {
      state = state.copyWith(error: 'Please enter a workout name');
      return false;
    }

    state = state.copyWith(isLoading: true);

    try {
      // Both Create and Update use CreateWorkoutSection/CreateSectionItem/CreateTargetSet
      final createSections = state.sections.asMap().entries.map((entry) {
        final idx = entry.key;
        final section = entry.value;

        final items = section.items.asMap().entries.map((itemEntry) {
          final itemIdx = itemEntry.key;
          final item = itemEntry.value;

          final createItem = CreateSectionItem()..displayOrder = itemIdx;

          if (item.isRest) {
            createItem
              ..itemType = SectionItemType.SECTION_ITEM_TYPE_REST
              ..restDurationSeconds = item.restDurationSeconds;
          } else {
            createItem
              ..itemType = SectionItemType.SECTION_ITEM_TYPE_EXERCISE
              ..exerciseId = item.exerciseId ?? '';

            for (final set in item.sets) {
              createItem.targetSets.add(CreateTargetSet()
                ..setNumber = set.setNumber
                ..targetWeightKg = set.targetWeightKg
                ..targetReps = set.targetReps
                ..targetTimeSeconds = set.targetTimeSeconds
                ..isBodyweight = set.isBodyweight);
            }
          }

          return createItem;
        }).toList();

        return CreateWorkoutSection()
          ..name = section.name
          ..displayOrder = idx
          ..isSuperset = section.isSuperset
          ..items.addAll(items);
      }).toList();

      if (state.id != null) {
        // Update existing workout
        final request = UpdateWorkoutRequest()
          ..id = state.id!
          ..userId = AppConfig.hardcodedUserId
          ..name = state.name
          ..sections.addAll(createSections);

        await workoutClient.updateWorkout(request);
      } else {
        // Create new workout
        final request = CreateWorkoutRequest()
          ..userId = AppConfig.hardcodedUserId
          ..name = state.name
          ..sections.addAll(createSections);

        await workoutClient.createWorkout(request);
      }

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

/// Provider for the workout builder
final workoutBuilderProvider =
    NotifierProvider<WorkoutBuilderNotifier, WorkoutBuilderState>(
        WorkoutBuilderNotifier.new);

/// Provider for exercise list in the search modal
final exerciseListProvider = FutureProvider<List<Exercise>>((ref) async {
  final request = ListExercisesRequest();
  final response = await exerciseClient.listExercises(request);
  return response.exercises;
});

/// Notifier for exercise search query
class ExerciseSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) => state = query;

  void clear() => state = '';
}

/// Exercise search query
final exerciseSearchQueryProvider =
    NotifierProvider<ExerciseSearchQueryNotifier, String>(
        ExerciseSearchQueryNotifier.new);

/// Filtered exercises based on search
final filteredExercisesProvider = Provider<List<Exercise>>((ref) {
  final exercisesAsync = ref.watch(exerciseListProvider);
  final query = ref.watch(exerciseSearchQueryProvider).toLowerCase();

  return exercisesAsync.when(
    data: (exercises) {
      if (query.isEmpty) return exercises;
      return exercises
          .where((e) => e.name.toLowerCase().contains(query))
          .toList();
    },
    loading: () => [],
    error: (_, _) => [],
  );
});
