package testutil

import (
	"context"
	"database/sql"
	"os"
	"path/filepath"
	"runtime"
	"testing"

	"github.com/jackc/pgx/v5/pgxpool"
	_ "github.com/jackc/pgx/v5/stdlib"
	"github.com/peterldowns/pgtestdb"
	"github.com/peterldowns/pgtestdb/migrators/goosemigrator"
)

// getProjectRoot returns the absolute path to the project root
func getProjectRoot() string {
	_, currentFile, _, _ := runtime.Caller(0)
	// currentFile is /path/to/project/internal/testutil/testdb.go
	// Go up 3 levels to get project root
	return filepath.Dir(filepath.Dir(filepath.Dir(currentFile)))
}

// getMigrationsPath returns the absolute path to the migrations directory
func getMigrationsPath() string {
	return filepath.Join(getProjectRoot(), "migrations")
}

// TestDBConfig holds the configuration for test database
type TestDBConfig struct {
	User     string
	Password string
	Host     string
	Port     string
	Database string
}

// DefaultTestDBConfig returns default local PostgreSQL configuration.
// Can be overridden with environment variables.
func DefaultTestDBConfig() TestDBConfig {
	cfg := TestDBConfig{
		User:     "postgres",
		Password: "password",
		Host:     "localhost",
		Port:     "5433", // Docker compose uses 5433 to avoid conflicts
		Database: "postgres",
	}

	if v := os.Getenv("PGUSER"); v != "" {
		cfg.User = v
	}
	if v := os.Getenv("PGPASSWORD"); v != "" {
		cfg.Password = v
	}
	if v := os.Getenv("PGHOST"); v != "" {
		cfg.Host = v
	}
	if v := os.Getenv("PGPORT"); v != "" {
		cfg.Port = v
	}
	if v := os.Getenv("PGDATABASE"); v != "" {
		cfg.Database = v
	}

	return cfg
}

// NewTestDB creates a new isolated test database using pgtestdb.
// The database is automatically cleaned up when the test completes.
// Uses the project's migrations directory automatically.
func NewTestDB(t *testing.T) *sql.DB {
	t.Helper()

	cfg := DefaultTestDBConfig()
	conf := pgtestdb.Config{
		DriverName: "pgx",
		User:       cfg.User,
		Password:   cfg.Password,
		Host:       cfg.Host,
		Port:       cfg.Port,
		Database:   cfg.Database,
		Options:    "sslmode=disable",
	}

	// Use os.DirFS to create a filesystem from the migrations directory
	// and pass "." as the relative path within that filesystem
	migrationsFS := os.DirFS(getMigrationsPath())
	migrator := goosemigrator.New(".", goosemigrator.WithFS(migrationsFS))

	return pgtestdb.New(t, conf, migrator)
}

// NewTestPool creates a pgxpool.Pool from a test database.
// This is useful when your code uses pgxpool directly.
func NewTestPool(t *testing.T) *pgxpool.Pool {
	t.Helper()

	db := NewTestDB(t)

	// Get the DSN from the database connection
	// pgtestdb sets up the database and we need to extract connection info
	connString := getDSNFromDB(t, db)

	pool, err := pgxpool.New(context.Background(), connString)
	if err != nil {
		t.Fatalf("failed to create pgxpool: %v", err)
	}

	t.Cleanup(func() {
		pool.Close()
	})

	return pool
}

// getDSNFromDB extracts the connection string from the sql.DB
func getDSNFromDB(t *testing.T, db *sql.DB) string {
	t.Helper()

	// Get the current database name
	var dbName string
	err := db.QueryRow("SELECT current_database()").Scan(&dbName)
	if err != nil {
		t.Fatalf("failed to get database name: %v", err)
	}

	cfg := DefaultTestDBConfig()
	return "postgres://" + cfg.User + ":" + cfg.Password + "@" + cfg.Host + ":" + cfg.Port + "/" + dbName + "?sslmode=disable"
}
