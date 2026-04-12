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

// ProgramDayTypeToString converts a proto ProgramDayType to its database string representation.
func ProgramDayTypeToString(t heftv1.ProgramDayType) string {
	switch t {
	case heftv1.ProgramDayType_PROGRAM_DAY_TYPE_WORKOUT:
		return "workout"
	case heftv1.ProgramDayType_PROGRAM_DAY_TYPE_REST:
		return "rest"
	case heftv1.ProgramDayType_PROGRAM_DAY_TYPE_UNASSIGNED:
		return "unassigned"
	default:
		return "unassigned"
	}
}

// StringToProgramDayType converts a database string to its proto ProgramDayType.
func StringToProgramDayType(s string) heftv1.ProgramDayType {
	switch s {
	case "workout":
		return heftv1.ProgramDayType_PROGRAM_DAY_TYPE_WORKOUT
	case "rest":
		return heftv1.ProgramDayType_PROGRAM_DAY_TYPE_REST
	case "unassigned":
		return heftv1.ProgramDayType_PROGRAM_DAY_TYPE_UNASSIGNED
	default:
		return heftv1.ProgramDayType_PROGRAM_DAY_TYPE_UNSPECIFIED
	}
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
