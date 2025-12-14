package config

import (
	"os"
	"strconv"

	"github.com/joho/godotenv"
)

type Config struct {
	SupabaseURL        string
	SupabaseAnonKey    string
	SupabaseServiceKey string
	DatabaseURL        string
	Port               string
	TestMode           bool
	JWTSecret          string
	JWTExpirationHours int
}

func Load() (*Config, error) {
	_ = godotenv.Load() // Ignore error if .env doesn't exist

	cfg := &Config{
		SupabaseURL:        getEnv("SUPABASE_URL", ""),
		SupabaseAnonKey:    getEnv("SUPABASE_ANON_KEY", ""),
		SupabaseServiceKey: getEnv("SUPABASE_SERVICE_KEY", ""),
		DatabaseURL:        getEnv("DATABASE_URL", ""),
		Port:               getEnv("PORT", "8080"),
		TestMode:           getEnv("TEST_MODE", "false") == "true",
		JWTSecret:          getEnv("JWT_SECRET", "heft-dev-secret-change-in-production"),
		JWTExpirationHours: getEnvInt("JWT_EXPIRATION_HOURS", 168), // 7 days default
	}

	return cfg, nil
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

func getEnvInt(key string, defaultValue int) int {
	if value := os.Getenv(key); value != "" {
		if intVal, err := strconv.Atoi(value); err == nil {
			return intVal
		}
	}
	return defaultValue
}
