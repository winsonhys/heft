//
//  Generated code. Do not modify.
//  source: common.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// Exercise type enum matching database
class ExerciseType extends $pb.ProtobufEnum {
  static const ExerciseType EXERCISE_TYPE_UNSPECIFIED = ExerciseType._(0, _omitEnumNames ? '' : 'EXERCISE_TYPE_UNSPECIFIED');
  static const ExerciseType EXERCISE_TYPE_WEIGHT_REPS = ExerciseType._(1, _omitEnumNames ? '' : 'EXERCISE_TYPE_WEIGHT_REPS');
  static const ExerciseType EXERCISE_TYPE_BODYWEIGHT_REPS = ExerciseType._(2, _omitEnumNames ? '' : 'EXERCISE_TYPE_BODYWEIGHT_REPS');
  static const ExerciseType EXERCISE_TYPE_TIME = ExerciseType._(3, _omitEnumNames ? '' : 'EXERCISE_TYPE_TIME');
  static const ExerciseType EXERCISE_TYPE_DISTANCE = ExerciseType._(4, _omitEnumNames ? '' : 'EXERCISE_TYPE_DISTANCE');
  static const ExerciseType EXERCISE_TYPE_CARDIO = ExerciseType._(5, _omitEnumNames ? '' : 'EXERCISE_TYPE_CARDIO');

  static const $core.List<ExerciseType> values = <ExerciseType> [
    EXERCISE_TYPE_UNSPECIFIED,
    EXERCISE_TYPE_WEIGHT_REPS,
    EXERCISE_TYPE_BODYWEIGHT_REPS,
    EXERCISE_TYPE_TIME,
    EXERCISE_TYPE_DISTANCE,
    EXERCISE_TYPE_CARDIO,
  ];

  static final $core.Map<$core.int, ExerciseType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static ExerciseType? valueOf($core.int value) => _byValue[value];

  const ExerciseType._($core.int v, $core.String n) : super(v, n);
}

/// Workout session status
class WorkoutStatus extends $pb.ProtobufEnum {
  static const WorkoutStatus WORKOUT_STATUS_UNSPECIFIED = WorkoutStatus._(0, _omitEnumNames ? '' : 'WORKOUT_STATUS_UNSPECIFIED');
  static const WorkoutStatus WORKOUT_STATUS_IN_PROGRESS = WorkoutStatus._(1, _omitEnumNames ? '' : 'WORKOUT_STATUS_IN_PROGRESS');
  static const WorkoutStatus WORKOUT_STATUS_COMPLETED = WorkoutStatus._(2, _omitEnumNames ? '' : 'WORKOUT_STATUS_COMPLETED');
  static const WorkoutStatus WORKOUT_STATUS_ABANDONED = WorkoutStatus._(3, _omitEnumNames ? '' : 'WORKOUT_STATUS_ABANDONED');

  static const $core.List<WorkoutStatus> values = <WorkoutStatus> [
    WORKOUT_STATUS_UNSPECIFIED,
    WORKOUT_STATUS_IN_PROGRESS,
    WORKOUT_STATUS_COMPLETED,
    WORKOUT_STATUS_ABANDONED,
  ];

  static final $core.Map<$core.int, WorkoutStatus> _byValue = $pb.ProtobufEnum.initByValue(values);
  static WorkoutStatus? valueOf($core.int value) => _byValue[value];

  const WorkoutStatus._($core.int v, $core.String n) : super(v, n);
}

/// Day of week. ISO ordering: Monday=1..Sunday=7.
class DayOfWeek extends $pb.ProtobufEnum {
  static const DayOfWeek DAY_OF_WEEK_UNSPECIFIED = DayOfWeek._(0, _omitEnumNames ? '' : 'DAY_OF_WEEK_UNSPECIFIED');
  static const DayOfWeek DAY_OF_WEEK_MONDAY = DayOfWeek._(1, _omitEnumNames ? '' : 'DAY_OF_WEEK_MONDAY');
  static const DayOfWeek DAY_OF_WEEK_TUESDAY = DayOfWeek._(2, _omitEnumNames ? '' : 'DAY_OF_WEEK_TUESDAY');
  static const DayOfWeek DAY_OF_WEEK_WEDNESDAY = DayOfWeek._(3, _omitEnumNames ? '' : 'DAY_OF_WEEK_WEDNESDAY');
  static const DayOfWeek DAY_OF_WEEK_THURSDAY = DayOfWeek._(4, _omitEnumNames ? '' : 'DAY_OF_WEEK_THURSDAY');
  static const DayOfWeek DAY_OF_WEEK_FRIDAY = DayOfWeek._(5, _omitEnumNames ? '' : 'DAY_OF_WEEK_FRIDAY');
  static const DayOfWeek DAY_OF_WEEK_SATURDAY = DayOfWeek._(6, _omitEnumNames ? '' : 'DAY_OF_WEEK_SATURDAY');
  static const DayOfWeek DAY_OF_WEEK_SUNDAY = DayOfWeek._(7, _omitEnumNames ? '' : 'DAY_OF_WEEK_SUNDAY');

  static const $core.List<DayOfWeek> values = <DayOfWeek> [
    DAY_OF_WEEK_UNSPECIFIED,
    DAY_OF_WEEK_MONDAY,
    DAY_OF_WEEK_TUESDAY,
    DAY_OF_WEEK_WEDNESDAY,
    DAY_OF_WEEK_THURSDAY,
    DAY_OF_WEEK_FRIDAY,
    DAY_OF_WEEK_SATURDAY,
    DAY_OF_WEEK_SUNDAY,
  ];

  static final $core.Map<$core.int, DayOfWeek> _byValue = $pb.ProtobufEnum.initByValue(values);
  static DayOfWeek? valueOf($core.int value) => _byValue[value];

  const DayOfWeek._($core.int v, $core.String n) : super(v, n);
}

/// Section item type
class SectionItemType extends $pb.ProtobufEnum {
  static const SectionItemType SECTION_ITEM_TYPE_UNSPECIFIED = SectionItemType._(0, _omitEnumNames ? '' : 'SECTION_ITEM_TYPE_UNSPECIFIED');
  static const SectionItemType SECTION_ITEM_TYPE_EXERCISE = SectionItemType._(1, _omitEnumNames ? '' : 'SECTION_ITEM_TYPE_EXERCISE');
  static const SectionItemType SECTION_ITEM_TYPE_REST = SectionItemType._(2, _omitEnumNames ? '' : 'SECTION_ITEM_TYPE_REST');

  static const $core.List<SectionItemType> values = <SectionItemType> [
    SECTION_ITEM_TYPE_UNSPECIFIED,
    SECTION_ITEM_TYPE_EXERCISE,
    SECTION_ITEM_TYPE_REST,
  ];

  static final $core.Map<$core.int, SectionItemType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static SectionItemType? valueOf($core.int value) => _byValue[value];

  const SectionItemType._($core.int v, $core.String n) : super(v, n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
