package convert

import heftv1 "github.com/heftyback/gen/heft/v1"

// ExerciseTypeToString converts a proto ExerciseType to its database string representation.
func ExerciseTypeToString(et heftv1.ExerciseType) string {
	switch et {
	case heftv1.ExerciseType_EXERCISE_TYPE_WEIGHT_REPS:
		return "weight_reps"
	case heftv1.ExerciseType_EXERCISE_TYPE_BODYWEIGHT_REPS:
		return "bodyweight_reps"
	case heftv1.ExerciseType_EXERCISE_TYPE_TIME:
		return "time"
	case heftv1.ExerciseType_EXERCISE_TYPE_DISTANCE:
		return "distance"
	case heftv1.ExerciseType_EXERCISE_TYPE_CARDIO:
		return "cardio"
	default:
		return ""
	}
}

// StringToExerciseType converts a database string to its proto ExerciseType.
func StringToExerciseType(s string) heftv1.ExerciseType {
	switch s {
	case "weight_reps":
		return heftv1.ExerciseType_EXERCISE_TYPE_WEIGHT_REPS
	case "bodyweight_reps":
		return heftv1.ExerciseType_EXERCISE_TYPE_BODYWEIGHT_REPS
	case "time":
		return heftv1.ExerciseType_EXERCISE_TYPE_TIME
	case "distance":
		return heftv1.ExerciseType_EXERCISE_TYPE_DISTANCE
	case "cardio":
		return heftv1.ExerciseType_EXERCISE_TYPE_CARDIO
	default:
		return heftv1.ExerciseType_EXERCISE_TYPE_UNSPECIFIED
	}
}

// SectionItemTypeToString converts a proto SectionItemType to its database string representation.
func SectionItemTypeToString(t heftv1.SectionItemType) string {
	switch t {
	case heftv1.SectionItemType_SECTION_ITEM_TYPE_EXERCISE:
		return "exercise"
	case heftv1.SectionItemType_SECTION_ITEM_TYPE_REST:
		return "rest"
	default:
		return "exercise"
	}
}

// StringToSectionItemType converts a database string to its proto SectionItemType.
func StringToSectionItemType(s string) heftv1.SectionItemType {
	switch s {
	case "exercise":
		return heftv1.SectionItemType_SECTION_ITEM_TYPE_EXERCISE
	case "rest":
		return heftv1.SectionItemType_SECTION_ITEM_TYPE_REST
	default:
		return heftv1.SectionItemType_SECTION_ITEM_TYPE_UNSPECIFIED
	}
}

// DayOfWeekToInt converts a proto DayOfWeek to its ISO integer (Monday=1..Sunday=7).
// Returns 0 for unspecified/invalid values.
func DayOfWeekToInt(d heftv1.DayOfWeek) int16 {
	switch d {
	case heftv1.DayOfWeek_DAY_OF_WEEK_MONDAY:
		return 1
	case heftv1.DayOfWeek_DAY_OF_WEEK_TUESDAY:
		return 2
	case heftv1.DayOfWeek_DAY_OF_WEEK_WEDNESDAY:
		return 3
	case heftv1.DayOfWeek_DAY_OF_WEEK_THURSDAY:
		return 4
	case heftv1.DayOfWeek_DAY_OF_WEEK_FRIDAY:
		return 5
	case heftv1.DayOfWeek_DAY_OF_WEEK_SATURDAY:
		return 6
	case heftv1.DayOfWeek_DAY_OF_WEEK_SUNDAY:
		return 7
	default:
		return 0
	}
}

// IntToDayOfWeek converts an ISO integer (Monday=1..Sunday=7) to its proto DayOfWeek.
func IntToDayOfWeek(i int16) heftv1.DayOfWeek {
	switch i {
	case 1:
		return heftv1.DayOfWeek_DAY_OF_WEEK_MONDAY
	case 2:
		return heftv1.DayOfWeek_DAY_OF_WEEK_TUESDAY
	case 3:
		return heftv1.DayOfWeek_DAY_OF_WEEK_WEDNESDAY
	case 4:
		return heftv1.DayOfWeek_DAY_OF_WEEK_THURSDAY
	case 5:
		return heftv1.DayOfWeek_DAY_OF_WEEK_FRIDAY
	case 6:
		return heftv1.DayOfWeek_DAY_OF_WEEK_SATURDAY
	case 7:
		return heftv1.DayOfWeek_DAY_OF_WEEK_SUNDAY
	default:
		return heftv1.DayOfWeek_DAY_OF_WEEK_UNSPECIFIED
	}
}

// TimeWeekdayToISO converts Go's time.Weekday (Sunday=0..Saturday=6) to ISO (Monday=1..Sunday=7).
func TimeWeekdayToISO(w int) int16 {
	if w == 0 {
		return 7
	}
	return int16(w)
}

// WorkoutStatusToString converts a proto WorkoutStatus to its database string representation.
func WorkoutStatusToString(s heftv1.WorkoutStatus) string {
	switch s {
	case heftv1.WorkoutStatus_WORKOUT_STATUS_IN_PROGRESS:
		return "in_progress"
	case heftv1.WorkoutStatus_WORKOUT_STATUS_COMPLETED:
		return "completed"
	case heftv1.WorkoutStatus_WORKOUT_STATUS_ABANDONED:
		return "abandoned"
	default:
		return ""
	}
}

// StringToWorkoutStatus converts a database string to its proto WorkoutStatus.
func StringToWorkoutStatus(s string) heftv1.WorkoutStatus {
	switch s {
	case "in_progress":
		return heftv1.WorkoutStatus_WORKOUT_STATUS_IN_PROGRESS
	case "completed":
		return heftv1.WorkoutStatus_WORKOUT_STATUS_COMPLETED
	case "abandoned":
		return heftv1.WorkoutStatus_WORKOUT_STATUS_ABANDONED
	default:
		return heftv1.WorkoutStatus_WORKOUT_STATUS_UNSPECIFIED
	}
}
