// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'session_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SessionModel {

 String get id; String get workoutTemplateId; String get name; List<SessionExerciseModel> get exercises; List<SessionRestItemModel> get restItems; int get completedSets; int get totalSets; int get durationSeconds; DateTime? get startedAt; DateTime? get completedAt; DateTime? get updatedAt; String get notes;
/// Create a copy of SessionModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionModelCopyWith<SessionModel> get copyWith => _$SessionModelCopyWithImpl<SessionModel>(this as SessionModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.workoutTemplateId, workoutTemplateId) || other.workoutTemplateId == workoutTemplateId)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.exercises, exercises)&&const DeepCollectionEquality().equals(other.restItems, restItems)&&(identical(other.completedSets, completedSets) || other.completedSets == completedSets)&&(identical(other.totalSets, totalSets) || other.totalSets == totalSets)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.notes, notes) || other.notes == notes));
}


@override
int get hashCode => Object.hash(runtimeType,id,workoutTemplateId,name,const DeepCollectionEquality().hash(exercises),const DeepCollectionEquality().hash(restItems),completedSets,totalSets,durationSeconds,startedAt,completedAt,updatedAt,notes);

@override
String toString() {
  return 'SessionModel(id: $id, workoutTemplateId: $workoutTemplateId, name: $name, exercises: $exercises, restItems: $restItems, completedSets: $completedSets, totalSets: $totalSets, durationSeconds: $durationSeconds, startedAt: $startedAt, completedAt: $completedAt, updatedAt: $updatedAt, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $SessionModelCopyWith<$Res>  {
  factory $SessionModelCopyWith(SessionModel value, $Res Function(SessionModel) _then) = _$SessionModelCopyWithImpl;
@useResult
$Res call({
 String id, String workoutTemplateId, String name, List<SessionExerciseModel> exercises, List<SessionRestItemModel> restItems, int completedSets, int totalSets, int durationSeconds, DateTime? startedAt, DateTime? completedAt, DateTime? updatedAt, String notes
});




}
/// @nodoc
class _$SessionModelCopyWithImpl<$Res>
    implements $SessionModelCopyWith<$Res> {
  _$SessionModelCopyWithImpl(this._self, this._then);

  final SessionModel _self;
  final $Res Function(SessionModel) _then;

/// Create a copy of SessionModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? workoutTemplateId = null,Object? name = null,Object? exercises = null,Object? restItems = null,Object? completedSets = null,Object? totalSets = null,Object? durationSeconds = null,Object? startedAt = freezed,Object? completedAt = freezed,Object? updatedAt = freezed,Object? notes = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,workoutTemplateId: null == workoutTemplateId ? _self.workoutTemplateId : workoutTemplateId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,exercises: null == exercises ? _self.exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<SessionExerciseModel>,restItems: null == restItems ? _self.restItems : restItems // ignore: cast_nullable_to_non_nullable
as List<SessionRestItemModel>,completedSets: null == completedSets ? _self.completedSets : completedSets // ignore: cast_nullable_to_non_nullable
as int,totalSets: null == totalSets ? _self.totalSets : totalSets // ignore: cast_nullable_to_non_nullable
as int,durationSeconds: null == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SessionModel].
extension SessionModelPatterns on SessionModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SessionModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SessionModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SessionModel value)  $default,){
final _that = this;
switch (_that) {
case _SessionModel():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SessionModel value)?  $default,){
final _that = this;
switch (_that) {
case _SessionModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String workoutTemplateId,  String name,  List<SessionExerciseModel> exercises,  List<SessionRestItemModel> restItems,  int completedSets,  int totalSets,  int durationSeconds,  DateTime? startedAt,  DateTime? completedAt,  DateTime? updatedAt,  String notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SessionModel() when $default != null:
return $default(_that.id,_that.workoutTemplateId,_that.name,_that.exercises,_that.restItems,_that.completedSets,_that.totalSets,_that.durationSeconds,_that.startedAt,_that.completedAt,_that.updatedAt,_that.notes);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String workoutTemplateId,  String name,  List<SessionExerciseModel> exercises,  List<SessionRestItemModel> restItems,  int completedSets,  int totalSets,  int durationSeconds,  DateTime? startedAt,  DateTime? completedAt,  DateTime? updatedAt,  String notes)  $default,) {final _that = this;
switch (_that) {
case _SessionModel():
return $default(_that.id,_that.workoutTemplateId,_that.name,_that.exercises,_that.restItems,_that.completedSets,_that.totalSets,_that.durationSeconds,_that.startedAt,_that.completedAt,_that.updatedAt,_that.notes);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String workoutTemplateId,  String name,  List<SessionExerciseModel> exercises,  List<SessionRestItemModel> restItems,  int completedSets,  int totalSets,  int durationSeconds,  DateTime? startedAt,  DateTime? completedAt,  DateTime? updatedAt,  String notes)?  $default,) {final _that = this;
switch (_that) {
case _SessionModel() when $default != null:
return $default(_that.id,_that.workoutTemplateId,_that.name,_that.exercises,_that.restItems,_that.completedSets,_that.totalSets,_that.durationSeconds,_that.startedAt,_that.completedAt,_that.updatedAt,_that.notes);case _:
  return null;

}
}

}

/// @nodoc


class _SessionModel implements SessionModel {
  const _SessionModel({required this.id, required this.workoutTemplateId, required this.name, required final  List<SessionExerciseModel> exercises, final  List<SessionRestItemModel> restItems = const [], this.completedSets = 0, this.totalSets = 0, this.durationSeconds = 0, this.startedAt, this.completedAt, this.updatedAt, this.notes = ''}): _exercises = exercises,_restItems = restItems;
  

@override final  String id;
@override final  String workoutTemplateId;
@override final  String name;
 final  List<SessionExerciseModel> _exercises;
@override List<SessionExerciseModel> get exercises {
  if (_exercises is EqualUnmodifiableListView) return _exercises;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_exercises);
}

 final  List<SessionRestItemModel> _restItems;
@override@JsonKey() List<SessionRestItemModel> get restItems {
  if (_restItems is EqualUnmodifiableListView) return _restItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_restItems);
}

@override@JsonKey() final  int completedSets;
@override@JsonKey() final  int totalSets;
@override@JsonKey() final  int durationSeconds;
@override final  DateTime? startedAt;
@override final  DateTime? completedAt;
@override final  DateTime? updatedAt;
@override@JsonKey() final  String notes;

/// Create a copy of SessionModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionModelCopyWith<_SessionModel> get copyWith => __$SessionModelCopyWithImpl<_SessionModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SessionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.workoutTemplateId, workoutTemplateId) || other.workoutTemplateId == workoutTemplateId)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._exercises, _exercises)&&const DeepCollectionEquality().equals(other._restItems, _restItems)&&(identical(other.completedSets, completedSets) || other.completedSets == completedSets)&&(identical(other.totalSets, totalSets) || other.totalSets == totalSets)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.notes, notes) || other.notes == notes));
}


@override
int get hashCode => Object.hash(runtimeType,id,workoutTemplateId,name,const DeepCollectionEquality().hash(_exercises),const DeepCollectionEquality().hash(_restItems),completedSets,totalSets,durationSeconds,startedAt,completedAt,updatedAt,notes);

@override
String toString() {
  return 'SessionModel(id: $id, workoutTemplateId: $workoutTemplateId, name: $name, exercises: $exercises, restItems: $restItems, completedSets: $completedSets, totalSets: $totalSets, durationSeconds: $durationSeconds, startedAt: $startedAt, completedAt: $completedAt, updatedAt: $updatedAt, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$SessionModelCopyWith<$Res> implements $SessionModelCopyWith<$Res> {
  factory _$SessionModelCopyWith(_SessionModel value, $Res Function(_SessionModel) _then) = __$SessionModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String workoutTemplateId, String name, List<SessionExerciseModel> exercises, List<SessionRestItemModel> restItems, int completedSets, int totalSets, int durationSeconds, DateTime? startedAt, DateTime? completedAt, DateTime? updatedAt, String notes
});




}
/// @nodoc
class __$SessionModelCopyWithImpl<$Res>
    implements _$SessionModelCopyWith<$Res> {
  __$SessionModelCopyWithImpl(this._self, this._then);

  final _SessionModel _self;
  final $Res Function(_SessionModel) _then;

/// Create a copy of SessionModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? workoutTemplateId = null,Object? name = null,Object? exercises = null,Object? restItems = null,Object? completedSets = null,Object? totalSets = null,Object? durationSeconds = null,Object? startedAt = freezed,Object? completedAt = freezed,Object? updatedAt = freezed,Object? notes = null,}) {
  return _then(_SessionModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,workoutTemplateId: null == workoutTemplateId ? _self.workoutTemplateId : workoutTemplateId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,exercises: null == exercises ? _self._exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<SessionExerciseModel>,restItems: null == restItems ? _self._restItems : restItems // ignore: cast_nullable_to_non_nullable
as List<SessionRestItemModel>,completedSets: null == completedSets ? _self.completedSets : completedSets // ignore: cast_nullable_to_non_nullable
as int,totalSets: null == totalSets ? _self.totalSets : totalSets // ignore: cast_nullable_to_non_nullable
as int,durationSeconds: null == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$SessionExerciseModel {

 String get id; String get exerciseId; String get exerciseName; String get sectionName; List<SessionSetModel> get sets; ExerciseType get exerciseType; int get displayOrder; String get notes; String? get supersetId;
/// Create a copy of SessionExerciseModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionExerciseModelCopyWith<SessionExerciseModel> get copyWith => _$SessionExerciseModelCopyWithImpl<SessionExerciseModel>(this as SessionExerciseModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionExerciseModel&&(identical(other.id, id) || other.id == id)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName)&&(identical(other.sectionName, sectionName) || other.sectionName == sectionName)&&const DeepCollectionEquality().equals(other.sets, sets)&&(identical(other.exerciseType, exerciseType) || other.exerciseType == exerciseType)&&(identical(other.displayOrder, displayOrder) || other.displayOrder == displayOrder)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.supersetId, supersetId) || other.supersetId == supersetId));
}


@override
int get hashCode => Object.hash(runtimeType,id,exerciseId,exerciseName,sectionName,const DeepCollectionEquality().hash(sets),exerciseType,displayOrder,notes,supersetId);

@override
String toString() {
  return 'SessionExerciseModel(id: $id, exerciseId: $exerciseId, exerciseName: $exerciseName, sectionName: $sectionName, sets: $sets, exerciseType: $exerciseType, displayOrder: $displayOrder, notes: $notes, supersetId: $supersetId)';
}


}

/// @nodoc
abstract mixin class $SessionExerciseModelCopyWith<$Res>  {
  factory $SessionExerciseModelCopyWith(SessionExerciseModel value, $Res Function(SessionExerciseModel) _then) = _$SessionExerciseModelCopyWithImpl;
@useResult
$Res call({
 String id, String exerciseId, String exerciseName, String sectionName, List<SessionSetModel> sets, ExerciseType exerciseType, int displayOrder, String notes, String? supersetId
});




}
/// @nodoc
class _$SessionExerciseModelCopyWithImpl<$Res>
    implements $SessionExerciseModelCopyWith<$Res> {
  _$SessionExerciseModelCopyWithImpl(this._self, this._then);

  final SessionExerciseModel _self;
  final $Res Function(SessionExerciseModel) _then;

/// Create a copy of SessionExerciseModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? exerciseId = null,Object? exerciseName = null,Object? sectionName = null,Object? sets = null,Object? exerciseType = null,Object? displayOrder = null,Object? notes = null,Object? supersetId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,exerciseName: null == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String,sectionName: null == sectionName ? _self.sectionName : sectionName // ignore: cast_nullable_to_non_nullable
as String,sets: null == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as List<SessionSetModel>,exerciseType: null == exerciseType ? _self.exerciseType : exerciseType // ignore: cast_nullable_to_non_nullable
as ExerciseType,displayOrder: null == displayOrder ? _self.displayOrder : displayOrder // ignore: cast_nullable_to_non_nullable
as int,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,supersetId: freezed == supersetId ? _self.supersetId : supersetId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SessionExerciseModel].
extension SessionExerciseModelPatterns on SessionExerciseModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SessionExerciseModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SessionExerciseModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SessionExerciseModel value)  $default,){
final _that = this;
switch (_that) {
case _SessionExerciseModel():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SessionExerciseModel value)?  $default,){
final _that = this;
switch (_that) {
case _SessionExerciseModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String exerciseId,  String exerciseName,  String sectionName,  List<SessionSetModel> sets,  ExerciseType exerciseType,  int displayOrder,  String notes,  String? supersetId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SessionExerciseModel() when $default != null:
return $default(_that.id,_that.exerciseId,_that.exerciseName,_that.sectionName,_that.sets,_that.exerciseType,_that.displayOrder,_that.notes,_that.supersetId);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String exerciseId,  String exerciseName,  String sectionName,  List<SessionSetModel> sets,  ExerciseType exerciseType,  int displayOrder,  String notes,  String? supersetId)  $default,) {final _that = this;
switch (_that) {
case _SessionExerciseModel():
return $default(_that.id,_that.exerciseId,_that.exerciseName,_that.sectionName,_that.sets,_that.exerciseType,_that.displayOrder,_that.notes,_that.supersetId);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String exerciseId,  String exerciseName,  String sectionName,  List<SessionSetModel> sets,  ExerciseType exerciseType,  int displayOrder,  String notes,  String? supersetId)?  $default,) {final _that = this;
switch (_that) {
case _SessionExerciseModel() when $default != null:
return $default(_that.id,_that.exerciseId,_that.exerciseName,_that.sectionName,_that.sets,_that.exerciseType,_that.displayOrder,_that.notes,_that.supersetId);case _:
  return null;

}
}

}

/// @nodoc


class _SessionExerciseModel implements SessionExerciseModel {
  const _SessionExerciseModel({required this.id, required this.exerciseId, required this.exerciseName, required this.sectionName, required final  List<SessionSetModel> sets, this.exerciseType = ExerciseType.EXERCISE_TYPE_UNSPECIFIED, this.displayOrder = 0, this.notes = '', this.supersetId}): _sets = sets;
  

@override final  String id;
@override final  String exerciseId;
@override final  String exerciseName;
@override final  String sectionName;
 final  List<SessionSetModel> _sets;
@override List<SessionSetModel> get sets {
  if (_sets is EqualUnmodifiableListView) return _sets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sets);
}

@override@JsonKey() final  ExerciseType exerciseType;
@override@JsonKey() final  int displayOrder;
@override@JsonKey() final  String notes;
@override final  String? supersetId;

/// Create a copy of SessionExerciseModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionExerciseModelCopyWith<_SessionExerciseModel> get copyWith => __$SessionExerciseModelCopyWithImpl<_SessionExerciseModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SessionExerciseModel&&(identical(other.id, id) || other.id == id)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName)&&(identical(other.sectionName, sectionName) || other.sectionName == sectionName)&&const DeepCollectionEquality().equals(other._sets, _sets)&&(identical(other.exerciseType, exerciseType) || other.exerciseType == exerciseType)&&(identical(other.displayOrder, displayOrder) || other.displayOrder == displayOrder)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.supersetId, supersetId) || other.supersetId == supersetId));
}


@override
int get hashCode => Object.hash(runtimeType,id,exerciseId,exerciseName,sectionName,const DeepCollectionEquality().hash(_sets),exerciseType,displayOrder,notes,supersetId);

@override
String toString() {
  return 'SessionExerciseModel(id: $id, exerciseId: $exerciseId, exerciseName: $exerciseName, sectionName: $sectionName, sets: $sets, exerciseType: $exerciseType, displayOrder: $displayOrder, notes: $notes, supersetId: $supersetId)';
}


}

/// @nodoc
abstract mixin class _$SessionExerciseModelCopyWith<$Res> implements $SessionExerciseModelCopyWith<$Res> {
  factory _$SessionExerciseModelCopyWith(_SessionExerciseModel value, $Res Function(_SessionExerciseModel) _then) = __$SessionExerciseModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String exerciseId, String exerciseName, String sectionName, List<SessionSetModel> sets, ExerciseType exerciseType, int displayOrder, String notes, String? supersetId
});




}
/// @nodoc
class __$SessionExerciseModelCopyWithImpl<$Res>
    implements _$SessionExerciseModelCopyWith<$Res> {
  __$SessionExerciseModelCopyWithImpl(this._self, this._then);

  final _SessionExerciseModel _self;
  final $Res Function(_SessionExerciseModel) _then;

/// Create a copy of SessionExerciseModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? exerciseId = null,Object? exerciseName = null,Object? sectionName = null,Object? sets = null,Object? exerciseType = null,Object? displayOrder = null,Object? notes = null,Object? supersetId = freezed,}) {
  return _then(_SessionExerciseModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,exerciseName: null == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String,sectionName: null == sectionName ? _self.sectionName : sectionName // ignore: cast_nullable_to_non_nullable
as String,sets: null == sets ? _self._sets : sets // ignore: cast_nullable_to_non_nullable
as List<SessionSetModel>,exerciseType: null == exerciseType ? _self.exerciseType : exerciseType // ignore: cast_nullable_to_non_nullable
as ExerciseType,displayOrder: null == displayOrder ? _self.displayOrder : displayOrder // ignore: cast_nullable_to_non_nullable
as int,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,supersetId: freezed == supersetId ? _self.supersetId : supersetId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$SessionSetModel {

 String get id; int get setNumber; double get weightKg; int get reps; int get timeSeconds; double get distanceM; bool get isBodyweight; bool get isCompleted; double get targetWeightKg; int get targetReps; int get targetTimeSeconds; double get rpe; String get notes; DateTime? get completedAt; int get restDurationSeconds;
/// Create a copy of SessionSetModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionSetModelCopyWith<SessionSetModel> get copyWith => _$SessionSetModelCopyWithImpl<SessionSetModel>(this as SessionSetModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionSetModel&&(identical(other.id, id) || other.id == id)&&(identical(other.setNumber, setNumber) || other.setNumber == setNumber)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.timeSeconds, timeSeconds) || other.timeSeconds == timeSeconds)&&(identical(other.distanceM, distanceM) || other.distanceM == distanceM)&&(identical(other.isBodyweight, isBodyweight) || other.isBodyweight == isBodyweight)&&(identical(other.isCompleted, isCompleted) || other.isCompleted == isCompleted)&&(identical(other.targetWeightKg, targetWeightKg) || other.targetWeightKg == targetWeightKg)&&(identical(other.targetReps, targetReps) || other.targetReps == targetReps)&&(identical(other.targetTimeSeconds, targetTimeSeconds) || other.targetTimeSeconds == targetTimeSeconds)&&(identical(other.rpe, rpe) || other.rpe == rpe)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.restDurationSeconds, restDurationSeconds) || other.restDurationSeconds == restDurationSeconds));
}


@override
int get hashCode => Object.hash(runtimeType,id,setNumber,weightKg,reps,timeSeconds,distanceM,isBodyweight,isCompleted,targetWeightKg,targetReps,targetTimeSeconds,rpe,notes,completedAt,restDurationSeconds);

@override
String toString() {
  return 'SessionSetModel(id: $id, setNumber: $setNumber, weightKg: $weightKg, reps: $reps, timeSeconds: $timeSeconds, distanceM: $distanceM, isBodyweight: $isBodyweight, isCompleted: $isCompleted, targetWeightKg: $targetWeightKg, targetReps: $targetReps, targetTimeSeconds: $targetTimeSeconds, rpe: $rpe, notes: $notes, completedAt: $completedAt, restDurationSeconds: $restDurationSeconds)';
}


}

/// @nodoc
abstract mixin class $SessionSetModelCopyWith<$Res>  {
  factory $SessionSetModelCopyWith(SessionSetModel value, $Res Function(SessionSetModel) _then) = _$SessionSetModelCopyWithImpl;
@useResult
$Res call({
 String id, int setNumber, double weightKg, int reps, int timeSeconds, double distanceM, bool isBodyweight, bool isCompleted, double targetWeightKg, int targetReps, int targetTimeSeconds, double rpe, String notes, DateTime? completedAt, int restDurationSeconds
});




}
/// @nodoc
class _$SessionSetModelCopyWithImpl<$Res>
    implements $SessionSetModelCopyWith<$Res> {
  _$SessionSetModelCopyWithImpl(this._self, this._then);

  final SessionSetModel _self;
  final $Res Function(SessionSetModel) _then;

/// Create a copy of SessionSetModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? setNumber = null,Object? weightKg = null,Object? reps = null,Object? timeSeconds = null,Object? distanceM = null,Object? isBodyweight = null,Object? isCompleted = null,Object? targetWeightKg = null,Object? targetReps = null,Object? targetTimeSeconds = null,Object? rpe = null,Object? notes = null,Object? completedAt = freezed,Object? restDurationSeconds = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,setNumber: null == setNumber ? _self.setNumber : setNumber // ignore: cast_nullable_to_non_nullable
as int,weightKg: null == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double,reps: null == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int,timeSeconds: null == timeSeconds ? _self.timeSeconds : timeSeconds // ignore: cast_nullable_to_non_nullable
as int,distanceM: null == distanceM ? _self.distanceM : distanceM // ignore: cast_nullable_to_non_nullable
as double,isBodyweight: null == isBodyweight ? _self.isBodyweight : isBodyweight // ignore: cast_nullable_to_non_nullable
as bool,isCompleted: null == isCompleted ? _self.isCompleted : isCompleted // ignore: cast_nullable_to_non_nullable
as bool,targetWeightKg: null == targetWeightKg ? _self.targetWeightKg : targetWeightKg // ignore: cast_nullable_to_non_nullable
as double,targetReps: null == targetReps ? _self.targetReps : targetReps // ignore: cast_nullable_to_non_nullable
as int,targetTimeSeconds: null == targetTimeSeconds ? _self.targetTimeSeconds : targetTimeSeconds // ignore: cast_nullable_to_non_nullable
as int,rpe: null == rpe ? _self.rpe : rpe // ignore: cast_nullable_to_non_nullable
as double,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,restDurationSeconds: null == restDurationSeconds ? _self.restDurationSeconds : restDurationSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SessionSetModel].
extension SessionSetModelPatterns on SessionSetModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SessionSetModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SessionSetModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SessionSetModel value)  $default,){
final _that = this;
switch (_that) {
case _SessionSetModel():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SessionSetModel value)?  $default,){
final _that = this;
switch (_that) {
case _SessionSetModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int setNumber,  double weightKg,  int reps,  int timeSeconds,  double distanceM,  bool isBodyweight,  bool isCompleted,  double targetWeightKg,  int targetReps,  int targetTimeSeconds,  double rpe,  String notes,  DateTime? completedAt,  int restDurationSeconds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SessionSetModel() when $default != null:
return $default(_that.id,_that.setNumber,_that.weightKg,_that.reps,_that.timeSeconds,_that.distanceM,_that.isBodyweight,_that.isCompleted,_that.targetWeightKg,_that.targetReps,_that.targetTimeSeconds,_that.rpe,_that.notes,_that.completedAt,_that.restDurationSeconds);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int setNumber,  double weightKg,  int reps,  int timeSeconds,  double distanceM,  bool isBodyweight,  bool isCompleted,  double targetWeightKg,  int targetReps,  int targetTimeSeconds,  double rpe,  String notes,  DateTime? completedAt,  int restDurationSeconds)  $default,) {final _that = this;
switch (_that) {
case _SessionSetModel():
return $default(_that.id,_that.setNumber,_that.weightKg,_that.reps,_that.timeSeconds,_that.distanceM,_that.isBodyweight,_that.isCompleted,_that.targetWeightKg,_that.targetReps,_that.targetTimeSeconds,_that.rpe,_that.notes,_that.completedAt,_that.restDurationSeconds);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int setNumber,  double weightKg,  int reps,  int timeSeconds,  double distanceM,  bool isBodyweight,  bool isCompleted,  double targetWeightKg,  int targetReps,  int targetTimeSeconds,  double rpe,  String notes,  DateTime? completedAt,  int restDurationSeconds)?  $default,) {final _that = this;
switch (_that) {
case _SessionSetModel() when $default != null:
return $default(_that.id,_that.setNumber,_that.weightKg,_that.reps,_that.timeSeconds,_that.distanceM,_that.isBodyweight,_that.isCompleted,_that.targetWeightKg,_that.targetReps,_that.targetTimeSeconds,_that.rpe,_that.notes,_that.completedAt,_that.restDurationSeconds);case _:
  return null;

}
}

}

/// @nodoc


class _SessionSetModel implements SessionSetModel {
  const _SessionSetModel({required this.id, required this.setNumber, this.weightKg = 0.0, this.reps = 0, this.timeSeconds = 0, this.distanceM = 0.0, this.isBodyweight = false, this.isCompleted = false, this.targetWeightKg = 0.0, this.targetReps = 0, this.targetTimeSeconds = 0, this.rpe = 0.0, this.notes = '', this.completedAt, this.restDurationSeconds = 0});
  

@override final  String id;
@override final  int setNumber;
@override@JsonKey() final  double weightKg;
@override@JsonKey() final  int reps;
@override@JsonKey() final  int timeSeconds;
@override@JsonKey() final  double distanceM;
@override@JsonKey() final  bool isBodyweight;
@override@JsonKey() final  bool isCompleted;
@override@JsonKey() final  double targetWeightKg;
@override@JsonKey() final  int targetReps;
@override@JsonKey() final  int targetTimeSeconds;
@override@JsonKey() final  double rpe;
@override@JsonKey() final  String notes;
@override final  DateTime? completedAt;
@override@JsonKey() final  int restDurationSeconds;

/// Create a copy of SessionSetModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionSetModelCopyWith<_SessionSetModel> get copyWith => __$SessionSetModelCopyWithImpl<_SessionSetModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SessionSetModel&&(identical(other.id, id) || other.id == id)&&(identical(other.setNumber, setNumber) || other.setNumber == setNumber)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.timeSeconds, timeSeconds) || other.timeSeconds == timeSeconds)&&(identical(other.distanceM, distanceM) || other.distanceM == distanceM)&&(identical(other.isBodyweight, isBodyweight) || other.isBodyweight == isBodyweight)&&(identical(other.isCompleted, isCompleted) || other.isCompleted == isCompleted)&&(identical(other.targetWeightKg, targetWeightKg) || other.targetWeightKg == targetWeightKg)&&(identical(other.targetReps, targetReps) || other.targetReps == targetReps)&&(identical(other.targetTimeSeconds, targetTimeSeconds) || other.targetTimeSeconds == targetTimeSeconds)&&(identical(other.rpe, rpe) || other.rpe == rpe)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.restDurationSeconds, restDurationSeconds) || other.restDurationSeconds == restDurationSeconds));
}


@override
int get hashCode => Object.hash(runtimeType,id,setNumber,weightKg,reps,timeSeconds,distanceM,isBodyweight,isCompleted,targetWeightKg,targetReps,targetTimeSeconds,rpe,notes,completedAt,restDurationSeconds);

@override
String toString() {
  return 'SessionSetModel(id: $id, setNumber: $setNumber, weightKg: $weightKg, reps: $reps, timeSeconds: $timeSeconds, distanceM: $distanceM, isBodyweight: $isBodyweight, isCompleted: $isCompleted, targetWeightKg: $targetWeightKg, targetReps: $targetReps, targetTimeSeconds: $targetTimeSeconds, rpe: $rpe, notes: $notes, completedAt: $completedAt, restDurationSeconds: $restDurationSeconds)';
}


}

/// @nodoc
abstract mixin class _$SessionSetModelCopyWith<$Res> implements $SessionSetModelCopyWith<$Res> {
  factory _$SessionSetModelCopyWith(_SessionSetModel value, $Res Function(_SessionSetModel) _then) = __$SessionSetModelCopyWithImpl;
@override @useResult
$Res call({
 String id, int setNumber, double weightKg, int reps, int timeSeconds, double distanceM, bool isBodyweight, bool isCompleted, double targetWeightKg, int targetReps, int targetTimeSeconds, double rpe, String notes, DateTime? completedAt, int restDurationSeconds
});




}
/// @nodoc
class __$SessionSetModelCopyWithImpl<$Res>
    implements _$SessionSetModelCopyWith<$Res> {
  __$SessionSetModelCopyWithImpl(this._self, this._then);

  final _SessionSetModel _self;
  final $Res Function(_SessionSetModel) _then;

/// Create a copy of SessionSetModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? setNumber = null,Object? weightKg = null,Object? reps = null,Object? timeSeconds = null,Object? distanceM = null,Object? isBodyweight = null,Object? isCompleted = null,Object? targetWeightKg = null,Object? targetReps = null,Object? targetTimeSeconds = null,Object? rpe = null,Object? notes = null,Object? completedAt = freezed,Object? restDurationSeconds = null,}) {
  return _then(_SessionSetModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,setNumber: null == setNumber ? _self.setNumber : setNumber // ignore: cast_nullable_to_non_nullable
as int,weightKg: null == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double,reps: null == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int,timeSeconds: null == timeSeconds ? _self.timeSeconds : timeSeconds // ignore: cast_nullable_to_non_nullable
as int,distanceM: null == distanceM ? _self.distanceM : distanceM // ignore: cast_nullable_to_non_nullable
as double,isBodyweight: null == isBodyweight ? _self.isBodyweight : isBodyweight // ignore: cast_nullable_to_non_nullable
as bool,isCompleted: null == isCompleted ? _self.isCompleted : isCompleted // ignore: cast_nullable_to_non_nullable
as bool,targetWeightKg: null == targetWeightKg ? _self.targetWeightKg : targetWeightKg // ignore: cast_nullable_to_non_nullable
as double,targetReps: null == targetReps ? _self.targetReps : targetReps // ignore: cast_nullable_to_non_nullable
as int,targetTimeSeconds: null == targetTimeSeconds ? _self.targetTimeSeconds : targetTimeSeconds // ignore: cast_nullable_to_non_nullable
as int,rpe: null == rpe ? _self.rpe : rpe // ignore: cast_nullable_to_non_nullable
as double,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,restDurationSeconds: null == restDurationSeconds ? _self.restDurationSeconds : restDurationSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$SessionRestItemModel {

 String get id; int get displayOrder; String get sectionName; int get restDurationSeconds; bool get isCompleted; DateTime? get completedAt;
/// Create a copy of SessionRestItemModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionRestItemModelCopyWith<SessionRestItemModel> get copyWith => _$SessionRestItemModelCopyWithImpl<SessionRestItemModel>(this as SessionRestItemModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionRestItemModel&&(identical(other.id, id) || other.id == id)&&(identical(other.displayOrder, displayOrder) || other.displayOrder == displayOrder)&&(identical(other.sectionName, sectionName) || other.sectionName == sectionName)&&(identical(other.restDurationSeconds, restDurationSeconds) || other.restDurationSeconds == restDurationSeconds)&&(identical(other.isCompleted, isCompleted) || other.isCompleted == isCompleted)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,displayOrder,sectionName,restDurationSeconds,isCompleted,completedAt);

@override
String toString() {
  return 'SessionRestItemModel(id: $id, displayOrder: $displayOrder, sectionName: $sectionName, restDurationSeconds: $restDurationSeconds, isCompleted: $isCompleted, completedAt: $completedAt)';
}


}

/// @nodoc
abstract mixin class $SessionRestItemModelCopyWith<$Res>  {
  factory $SessionRestItemModelCopyWith(SessionRestItemModel value, $Res Function(SessionRestItemModel) _then) = _$SessionRestItemModelCopyWithImpl;
@useResult
$Res call({
 String id, int displayOrder, String sectionName, int restDurationSeconds, bool isCompleted, DateTime? completedAt
});




}
/// @nodoc
class _$SessionRestItemModelCopyWithImpl<$Res>
    implements $SessionRestItemModelCopyWith<$Res> {
  _$SessionRestItemModelCopyWithImpl(this._self, this._then);

  final SessionRestItemModel _self;
  final $Res Function(SessionRestItemModel) _then;

/// Create a copy of SessionRestItemModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? displayOrder = null,Object? sectionName = null,Object? restDurationSeconds = null,Object? isCompleted = null,Object? completedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,displayOrder: null == displayOrder ? _self.displayOrder : displayOrder // ignore: cast_nullable_to_non_nullable
as int,sectionName: null == sectionName ? _self.sectionName : sectionName // ignore: cast_nullable_to_non_nullable
as String,restDurationSeconds: null == restDurationSeconds ? _self.restDurationSeconds : restDurationSeconds // ignore: cast_nullable_to_non_nullable
as int,isCompleted: null == isCompleted ? _self.isCompleted : isCompleted // ignore: cast_nullable_to_non_nullable
as bool,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SessionRestItemModel].
extension SessionRestItemModelPatterns on SessionRestItemModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SessionRestItemModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SessionRestItemModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SessionRestItemModel value)  $default,){
final _that = this;
switch (_that) {
case _SessionRestItemModel():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SessionRestItemModel value)?  $default,){
final _that = this;
switch (_that) {
case _SessionRestItemModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int displayOrder,  String sectionName,  int restDurationSeconds,  bool isCompleted,  DateTime? completedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SessionRestItemModel() when $default != null:
return $default(_that.id,_that.displayOrder,_that.sectionName,_that.restDurationSeconds,_that.isCompleted,_that.completedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int displayOrder,  String sectionName,  int restDurationSeconds,  bool isCompleted,  DateTime? completedAt)  $default,) {final _that = this;
switch (_that) {
case _SessionRestItemModel():
return $default(_that.id,_that.displayOrder,_that.sectionName,_that.restDurationSeconds,_that.isCompleted,_that.completedAt);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int displayOrder,  String sectionName,  int restDurationSeconds,  bool isCompleted,  DateTime? completedAt)?  $default,) {final _that = this;
switch (_that) {
case _SessionRestItemModel() when $default != null:
return $default(_that.id,_that.displayOrder,_that.sectionName,_that.restDurationSeconds,_that.isCompleted,_that.completedAt);case _:
  return null;

}
}

}

/// @nodoc


class _SessionRestItemModel implements SessionRestItemModel {
  const _SessionRestItemModel({required this.id, required this.displayOrder, required this.sectionName, required this.restDurationSeconds, this.isCompleted = false, this.completedAt});
  

@override final  String id;
@override final  int displayOrder;
@override final  String sectionName;
@override final  int restDurationSeconds;
@override@JsonKey() final  bool isCompleted;
@override final  DateTime? completedAt;

/// Create a copy of SessionRestItemModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionRestItemModelCopyWith<_SessionRestItemModel> get copyWith => __$SessionRestItemModelCopyWithImpl<_SessionRestItemModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SessionRestItemModel&&(identical(other.id, id) || other.id == id)&&(identical(other.displayOrder, displayOrder) || other.displayOrder == displayOrder)&&(identical(other.sectionName, sectionName) || other.sectionName == sectionName)&&(identical(other.restDurationSeconds, restDurationSeconds) || other.restDurationSeconds == restDurationSeconds)&&(identical(other.isCompleted, isCompleted) || other.isCompleted == isCompleted)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,displayOrder,sectionName,restDurationSeconds,isCompleted,completedAt);

@override
String toString() {
  return 'SessionRestItemModel(id: $id, displayOrder: $displayOrder, sectionName: $sectionName, restDurationSeconds: $restDurationSeconds, isCompleted: $isCompleted, completedAt: $completedAt)';
}


}

/// @nodoc
abstract mixin class _$SessionRestItemModelCopyWith<$Res> implements $SessionRestItemModelCopyWith<$Res> {
  factory _$SessionRestItemModelCopyWith(_SessionRestItemModel value, $Res Function(_SessionRestItemModel) _then) = __$SessionRestItemModelCopyWithImpl;
@override @useResult
$Res call({
 String id, int displayOrder, String sectionName, int restDurationSeconds, bool isCompleted, DateTime? completedAt
});




}
/// @nodoc
class __$SessionRestItemModelCopyWithImpl<$Res>
    implements _$SessionRestItemModelCopyWith<$Res> {
  __$SessionRestItemModelCopyWithImpl(this._self, this._then);

  final _SessionRestItemModel _self;
  final $Res Function(_SessionRestItemModel) _then;

/// Create a copy of SessionRestItemModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? displayOrder = null,Object? sectionName = null,Object? restDurationSeconds = null,Object? isCompleted = null,Object? completedAt = freezed,}) {
  return _then(_SessionRestItemModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,displayOrder: null == displayOrder ? _self.displayOrder : displayOrder // ignore: cast_nullable_to_non_nullable
as int,sectionName: null == sectionName ? _self.sectionName : sectionName // ignore: cast_nullable_to_non_nullable
as String,restDurationSeconds: null == restDurationSeconds ? _self.restDurationSeconds : restDurationSeconds // ignore: cast_nullable_to_non_nullable
as int,isCompleted: null == isCompleted ? _self.isCompleted : isCompleted // ignore: cast_nullable_to_non_nullable
as bool,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
