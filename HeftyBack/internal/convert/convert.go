// Package convert provides type conversion utilities for nullable pointer types.
package convert

// Int32PtrToIntPtr converts *int32 to *int
func Int32PtrToIntPtr(i *int32) *int {
	if i == nil {
		return nil
	}
	v := int(*i)
	return &v
}

// IntPtrToInt32Ptr converts *int to *int32
func IntPtrToInt32Ptr(i *int) *int32 {
	if i == nil {
		return nil
	}
	v := int32(*i)
	return &v
}

// DerefString returns the dereferenced string or empty string if nil
func DerefString(s *string) string {
	if s == nil {
		return ""
	}
	return *s
}

// DerefInt returns the dereferenced int or 0 if nil
func DerefInt(i *int) int {
	if i == nil {
		return 0
	}
	return *i
}

// DerefInt32 returns the dereferenced int32 or 0 if nil
func DerefInt32(i *int32) int32 {
	if i == nil {
		return 0
	}
	return *i
}

// DerefFloat64 returns the dereferenced float64 or 0.0 if nil
func DerefFloat64(f *float64) float64 {
	if f == nil {
		return 0.0
	}
	return *f
}

// StringPtr returns a pointer to the given string
func StringPtr(s string) *string {
	return &s
}

// IntPtr returns a pointer to the given int
func IntPtr(i int) *int {
	return &i
}

// Int32Ptr returns a pointer to the given int32
func Int32Ptr(i int32) *int32 {
	return &i
}

// Float64Ptr returns a pointer to the given float64
func Float64Ptr(f float64) *float64 {
	return &f
}
