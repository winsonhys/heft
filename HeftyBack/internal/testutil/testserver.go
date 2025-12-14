package testutil

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"connectrpc.com/connect"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/heftyback/gen/heft/v1/heftv1connect"
	"github.com/heftyback/internal/auth"
	"github.com/heftyback/internal/handlers"
	"github.com/heftyback/internal/middleware"
	"github.com/heftyback/internal/repository"
)

// TestServer wraps an httptest.Server with Connect-RPC clients
type TestServer struct {
	Server         *httptest.Server
	AuthClient     heftv1connect.AuthServiceClient
	UserClient     heftv1connect.UserServiceClient
	ExerciseClient heftv1connect.ExerciseServiceClient
	SessionClient  heftv1connect.SessionServiceClient
	WorkoutClient  heftv1connect.WorkoutServiceClient
	ProgramClient  heftv1connect.ProgramServiceClient
	ProgressClient heftv1connect.ProgressServiceClient
	Pool           *pgxpool.Pool
	JWTManager     *auth.JWTManager
}

// NewTestServer creates a test HTTP server with all services wired up
func NewTestServer(t *testing.T, pool *pgxpool.Pool) *TestServer {
	t.Helper()

	// Initialize JWT manager for tests
	jwtManager := auth.NewJWTManager("test-secret-key-for-testing", 24)

	// Initialize repositories
	authRepo := repository.NewAuthRepository(pool)
	userRepo := repository.NewUserRepository(pool)
	exerciseRepo := repository.NewExerciseRepository(pool)
	sessionRepo := repository.NewSessionRepository(pool)
	workoutRepo := repository.NewWorkoutRepository(pool)
	programRepo := repository.NewProgramRepository(pool)
	progressRepo := repository.NewProgressRepository(pool)

	// Initialize handlers
	authHandler := handlers.NewAuthHandler(authRepo, jwtManager)
	userHandler := handlers.NewUserHandler(userRepo)
	exerciseHandler := handlers.NewExerciseHandler(exerciseRepo)
	sessionHandler := handlers.NewSessionHandler(sessionRepo, workoutRepo)
	workoutHandler := handlers.NewWorkoutHandler(workoutRepo)
	programHandler := handlers.NewProgramHandler(programRepo, workoutRepo)
	progressHandler := handlers.NewProgressHandler(progressRepo, exerciseRepo)

	// Create auth interceptor
	authInterceptor := middleware.NewAuthInterceptor(jwtManager)
	interceptors := connect.WithInterceptors(authInterceptor)

	// Create HTTP mux
	mux := http.NewServeMux()

	// Register Connect services with auth interceptor
	authPath, authHTTPHandler := heftv1connect.NewAuthServiceHandler(authHandler, interceptors)
	userPath, userHTTPHandler := heftv1connect.NewUserServiceHandler(userHandler, interceptors)
	exercisePath, exerciseHTTPHandler := heftv1connect.NewExerciseServiceHandler(exerciseHandler, interceptors)
	sessionPath, sessionHTTPHandler := heftv1connect.NewSessionServiceHandler(sessionHandler, interceptors)
	workoutPath, workoutHTTPHandler := heftv1connect.NewWorkoutServiceHandler(workoutHandler, interceptors)
	programPath, programHTTPHandler := heftv1connect.NewProgramServiceHandler(programHandler, interceptors)
	progressPath, progressHTTPHandler := heftv1connect.NewProgressServiceHandler(progressHandler, interceptors)

	mux.Handle(authPath, authHTTPHandler)
	mux.Handle(userPath, userHTTPHandler)
	mux.Handle(exercisePath, exerciseHTTPHandler)
	mux.Handle(sessionPath, sessionHTTPHandler)
	mux.Handle(workoutPath, workoutHTTPHandler)
	mux.Handle(programPath, programHTTPHandler)
	mux.Handle(progressPath, progressHTTPHandler)

	// Create test server
	server := httptest.NewServer(mux)
	t.Cleanup(func() {
		server.Close()
	})

	// Create clients
	httpClient := server.Client()
	authClient := heftv1connect.NewAuthServiceClient(httpClient, server.URL)
	userClient := heftv1connect.NewUserServiceClient(httpClient, server.URL)
	exerciseClient := heftv1connect.NewExerciseServiceClient(httpClient, server.URL)
	sessionClient := heftv1connect.NewSessionServiceClient(httpClient, server.URL)
	workoutClient := heftv1connect.NewWorkoutServiceClient(httpClient, server.URL)
	programClient := heftv1connect.NewProgramServiceClient(httpClient, server.URL)
	progressClient := heftv1connect.NewProgressServiceClient(httpClient, server.URL)

	return &TestServer{
		Server:         server,
		AuthClient:     authClient,
		UserClient:     userClient,
		ExerciseClient: exerciseClient,
		SessionClient:  sessionClient,
		WorkoutClient:  workoutClient,
		ProgramClient:  programClient,
		ProgressClient: progressClient,
		Pool:           pool,
		JWTManager:     jwtManager,
	}
}

// NewTestServerWithMocks creates a test server with injectable mock repositories
func NewTestServerWithMocks(
	t *testing.T,
	userRepo repository.UserRepositoryInterface,
	exerciseRepo repository.ExerciseRepositoryInterface,
) *TestServer {
	t.Helper()

	// Initialize handlers with mocks
	userHandler := handlers.NewUserHandler(userRepo)
	exerciseHandler := handlers.NewExerciseHandler(exerciseRepo)

	// Create HTTP mux
	mux := http.NewServeMux()

	// Register Connect services
	userPath, userHTTPHandler := heftv1connect.NewUserServiceHandler(userHandler)
	exercisePath, exerciseHTTPHandler := heftv1connect.NewExerciseServiceHandler(exerciseHandler)

	mux.Handle(userPath, userHTTPHandler)
	mux.Handle(exercisePath, exerciseHTTPHandler)

	// Create test server
	server := httptest.NewServer(mux)
	t.Cleanup(func() {
		server.Close()
	})

	// Create clients
	httpClient := server.Client()
	userClient := heftv1connect.NewUserServiceClient(httpClient, server.URL)
	exerciseClient := heftv1connect.NewExerciseServiceClient(httpClient, server.URL)

	return &TestServer{
		Server:         server,
		UserClient:     userClient,
		ExerciseClient: exerciseClient,
	}
}

// GenerateAuthToken generates a JWT token for testing authenticated requests
func (ts *TestServer) GenerateAuthToken(userID string) string {
	token, _, _ := ts.JWTManager.GenerateToken(userID)
	return token
}

// AuthHeader returns the Authorization header value for a given user
func (ts *TestServer) AuthHeader(userID string) string {
	return "Bearer " + ts.GenerateAuthToken(userID)
}
