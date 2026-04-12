import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/client.dart';
import '../../../shared/widgets/exercise_picker_modal.dart';
import '../providers/workout_builder_providers.dart';

/// Exercise search modal with Riverpod-powered search and remote fallback.
///
/// Thin wrapper around [ExercisePickerModal]: fetches/filters exercises via
/// providers and passes the resulting list to the shared picker UI.
class ExerciseSearchModal extends HookConsumerWidget {
  final Function(Exercise) onSelect;

  const ExerciseSearchModal({
    super.key,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercises = ref.watch(filteredExercisesProvider);
    final exercisesAsync = ref.watch(exerciseListProvider);
    final debouncedQuery = useState('');

    // Debounce timer for remote search
    useEffect(() {
      final query = ref.read(exerciseSearchQueryProvider);
      if (query.isEmpty) {
        debouncedQuery.value = '';
        return null;
      }
      final timer = Timer(const Duration(milliseconds: 300), () {
        debouncedQuery.value = query;
      });
      return timer.cancel;
    }, [ref.watch(exerciseSearchQueryProvider)]);

    // Watch remote search results when debounced query is set
    final remoteSearchAsync = debouncedQuery.value.isNotEmpty
        ? ref.watch(searchExercisesRemoteProvider(debouncedQuery.value))
        : null;

    // Reset search query on mount (scheduled after build)
    useEffect(() {
      Future.microtask(() {
        ref.read(exerciseSearchQueryProvider.notifier).clear();
      });
      return null;
    }, []);

    return exercisesAsync.when(
      loading: () => ExercisePickerModal(
        title: 'Add Exercise',
        exercises: const [],
        onSelect: onSelect,
      ),
      error: (_, _) => ExercisePickerModal(
        title: 'Add Exercise',
        exercises: const [],
        onSelect: onSelect,
      ),
      data: (_) {
        final displayExercises = remoteSearchAsync?.when(
              data: (remoteExercises) => remoteExercises,
              loading: () => exercises,
              error: (_, _) => exercises,
            ) ??
            exercises;

        return ExercisePickerModal(
          title: 'Add Exercise',
          exercises: displayExercises,
          onSelect: onSelect,
          onSearchChanged: (query) {
            ref.read(exerciseSearchQueryProvider.notifier).setQuery(query);
          },
        );
      },
    );
  }
}
