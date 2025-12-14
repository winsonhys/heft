package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"connectrpc.com/connect"
	"github.com/rs/cors"
	"golang.org/x/net/http2"
	"golang.org/x/net/http2/h2c"

	"github.com/heftyback/gen/heft/v1/heftv1connect"
	"github.com/heftyback/internal/auth"
	"github.com/heftyback/internal/config"
	"github.com/heftyback/internal/db"
	"github.com/heftyback/internal/handlers"
	"github.com/heftyback/internal/middleware"
	"github.com/heftyback/internal/repository"
)

func main() {
	// Load configuration
	cfg, err := config.Load()
	if err != nil {
		log.Fatalf("Failed to load config: %v", err)
	}

	// Initialize database connection
	ctx := context.Background()
	database, err := db.New(ctx)
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}
	defer database.Close()

	log.Println("Connected to database")

	// Initialize JWT manager
	jwtManager := auth.NewJWTManager(cfg.JWTSecret, cfg.JWTExpirationHours)

	// Initialize repositories
	authRepo := repository.NewAuthRepository(database.Pool)
	userRepo := repository.NewUserRepository(database.Pool)
	exerciseRepo := repository.NewExerciseRepository(database.Pool)
	workoutRepo := repository.NewWorkoutRepository(database.Pool)
	programRepo := repository.NewProgramRepository(database.Pool)
	sessionRepo := repository.NewSessionRepository(database.Pool)
	progressRepo := repository.NewProgressRepository(database.Pool)

	// Initialize handlers
	authHandler := handlers.NewAuthHandler(authRepo, jwtManager)
	userHandler := handlers.NewUserHandler(userRepo)
	exerciseHandler := handlers.NewExerciseHandler(exerciseRepo)
	workoutHandler := handlers.NewWorkoutHandler(workoutRepo)
	programHandler := handlers.NewProgramHandler(programRepo, workoutRepo)
	sessionHandler := handlers.NewSessionHandler(sessionRepo, workoutRepo)
	progressHandler := handlers.NewProgressHandler(progressRepo, exerciseRepo)

	// Create interceptors (auth first, then logging)
	interceptors := connect.WithInterceptors(
		middleware.NewAuthInterceptor(jwtManager),
		middleware.NewLoggingInterceptor(),
	)

	// Create HTTP mux
	mux := http.NewServeMux()

	// Health check endpoint for Docker/k8s
	healthHandler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodGet && r.Method != http.MethodHead {
			w.WriteHeader(http.StatusOK)
			return
		}
		w.WriteHeader(http.StatusOK)
	})

	// Test reset endpoint - only available when TEST_MODE=true
	if cfg.TestMode {
		log.Println("TEST_MODE enabled - /test/reset endpoint available")
		mux.HandleFunc("/test/reset", func(w http.ResponseWriter, r *http.Request) {
			if r.Method != http.MethodPost {
				http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
				return
			}

			// Truncate tables in correct order (respecting FK constraints)
			// Keep users, exercise_categories, and system exercises (seed data)
			queries := []string{
				// Clear session data first (depends on workouts)
				`DELETE FROM session_sets`,
				`DELETE FROM session_exercises`,
				`DELETE FROM workout_sessions`,
				// Clear progress data
				`DELETE FROM personal_records`,
				`DELETE FROM exercise_history`,
				// Clear workout structure
				`DELETE FROM exercise_target_sets`,
				`DELETE FROM section_items`,
				`DELETE FROM workout_sections`,
				// Clear program data
				`DELETE FROM program_days`,
				`DELETE FROM programs`,
				// Clear workout templates
				`DELETE FROM workout_templates`,
				// Clear custom exercises (keep system ones)
				`DELETE FROM exercises WHERE is_system = false`,
				// Clear weight logs
				`DELETE FROM weight_logs`,
			}

			for _, q := range queries {
				if _, err := database.Pool.Exec(r.Context(), q); err != nil {
					log.Printf("Test reset error on query %q: %v", q, err)
					http.Error(w, fmt.Sprintf("Reset failed: %v", err), http.StatusInternalServerError)
					return
				}
			}

			w.Header().Set("Content-Type", "application/json")
			w.WriteHeader(http.StatusOK)
			w.Write([]byte(`{"status":"reset_complete"}`))
		})
	}

	// Register Connect services
	authPath, authHTTPHandler := heftv1connect.NewAuthServiceHandler(authHandler, interceptors)
	userPath, userHTTPHandler := heftv1connect.NewUserServiceHandler(userHandler, interceptors)
	exercisePath, exerciseHTTPHandler := heftv1connect.NewExerciseServiceHandler(exerciseHandler, interceptors)
	workoutPath, workoutHTTPHandler := heftv1connect.NewWorkoutServiceHandler(workoutHandler, interceptors)
	programPath, programHTTPHandler := heftv1connect.NewProgramServiceHandler(programHandler, interceptors)
	sessionPath, sessionHTTPHandler := heftv1connect.NewSessionServiceHandler(sessionHandler, interceptors)
	progressPath, progressHTTPHandler := heftv1connect.NewProgressServiceHandler(progressHandler, interceptors)

	mux.Handle(authPath, authHTTPHandler)
	mux.Handle(userPath, userHTTPHandler)
	mux.Handle(exercisePath, exerciseHTTPHandler)
	mux.Handle(workoutPath, workoutHTTPHandler)
	mux.Handle(programPath, programHTTPHandler)
	mux.Handle(sessionPath, sessionHTTPHandler)
	mux.Handle(progressPath, progressHTTPHandler)

	// Setup CORS
	corsHandler := cors.New(cors.Options{
		AllowedOrigins:   []string{"*"},
		AllowedMethods:   []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowedHeaders:   []string{"Accept", "Authorization", "Content-Type", "Connect-Protocol-Version"},
		ExposedHeaders:   []string{"Connect-Protocol-Version"},
		AllowCredentials: false,
		MaxAge:           300,
	})

	// Create server with h2c (HTTP/2 cleartext) support
	addr := fmt.Sprintf(":%s", cfg.Port)
	rootHandler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path == "/" || r.URL.Path == "/health" {
			healthHandler.ServeHTTP(w, r)
			return
		}
		corsHandler.Handler(
			h2c.NewHandler(mux, &http2.Server{}),
		).ServeHTTP(w, r)
	})
	server := &http.Server{
		Addr:         addr,
		Handler:      rootHandler,
		ReadTimeout:  30 * time.Second,
		WriteTimeout: 30 * time.Second,
		IdleTimeout:  120 * time.Second,
	}

	// Start server in goroutine
	go func() {
		log.Printf("Server starting on %s", addr)
		log.Printf("Services registered:")
		log.Printf("  - AuthService:     %s", authPath)
		log.Printf("  - UserService:     %s", userPath)
		log.Printf("  - ExerciseService: %s", exercisePath)
		log.Printf("  - WorkoutService:  %s", workoutPath)
		log.Printf("  - ProgramService:  %s", programPath)
		log.Printf("  - SessionService:  %s", sessionPath)
		log.Printf("  - ProgressService: %s", progressPath)
		if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("Server error: %v", err)
		}
	}()

	// Wait for interrupt signal
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	log.Println("Shutting down server...")

	// Graceful shutdown
	shutdownCtx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	if err := server.Shutdown(shutdownCtx); err != nil {
		log.Fatalf("Server shutdown error: %v", err)
	}

	log.Println("Server stopped")
}
