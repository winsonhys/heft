-- +goose Up
-- +goose StatementBegin

-- ============================================================================
-- HEFT WORKOUT TRACKER - DATABASE SCHEMA
-- ============================================================================

-- ============================================================================
-- CORE ENTITIES
-- ============================================================================

-- Users table - Core user information and preferences
CREATE TABLE users (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email           VARCHAR(255) UNIQUE NOT NULL,
    password_hash   VARCHAR(255) NOT NULL,
    display_name    VARCHAR(100),
    avatar_url      VARCHAR(500),

    -- Settings
    use_pounds      BOOLEAN DEFAULT FALSE,
    rest_timer_seconds INTEGER DEFAULT 120,
    member_since    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Timestamps
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- User body weight log
CREATE TABLE weight_logs (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    weight_kg       DECIMAL(5,2) NOT NULL,
    logged_date     DATE NOT NULL,
    notes           TEXT,

    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    UNIQUE(user_id, logged_date)
);

-- ============================================================================
-- EXERCISE LIBRARY
-- ============================================================================

-- Exercise categories for organization
CREATE TABLE exercise_categories (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name            VARCHAR(100) NOT NULL UNIQUE,
    display_order   INTEGER DEFAULT 0,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Exercise type enum
CREATE TYPE exercise_type AS ENUM (
    'weight_reps',
    'bodyweight_reps',
    'time',
    'distance',
    'cardio'
);

-- Master exercise library
CREATE TABLE exercises (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name            VARCHAR(200) NOT NULL,
    category_id     UUID REFERENCES exercise_categories(id),
    exercise_type   exercise_type NOT NULL DEFAULT 'weight_reps',
    description     TEXT,

    is_system       BOOLEAN DEFAULT TRUE,
    created_by      UUID REFERENCES users(id),

    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    UNIQUE(name, created_by)
);

-- ============================================================================
-- WORKOUT TEMPLATES
-- ============================================================================

-- Workout templates - Reusable workout structures
CREATE TABLE workout_templates (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name            VARCHAR(200) NOT NULL,
    description     TEXT,

    total_exercises INTEGER DEFAULT 0,
    total_sets      INTEGER DEFAULT 0,
    estimated_duration_minutes INTEGER,

    is_archived     BOOLEAN DEFAULT FALSE,

    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Workout sections
CREATE TABLE workout_sections (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workout_template_id UUID NOT NULL REFERENCES workout_templates(id) ON DELETE CASCADE,
    name            VARCHAR(100) NOT NULL,
    display_order   INTEGER NOT NULL,
    is_superset     BOOLEAN DEFAULT FALSE,

    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    UNIQUE(workout_template_id, display_order)
);

-- Section items
CREATE TYPE section_item_type AS ENUM ('exercise', 'rest');

CREATE TABLE section_items (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    section_id      UUID NOT NULL REFERENCES workout_sections(id) ON DELETE CASCADE,
    item_type       section_item_type NOT NULL,
    display_order   INTEGER NOT NULL,

    exercise_id     UUID REFERENCES exercises(id),
    rest_duration_seconds INTEGER,

    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    UNIQUE(section_id, display_order)
);

-- Target sets for exercise items
CREATE TABLE exercise_target_sets (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    section_item_id UUID NOT NULL REFERENCES section_items(id) ON DELETE CASCADE,
    set_number      INTEGER NOT NULL,

    target_weight_kg    DECIMAL(6,2),
    target_reps         INTEGER,
    target_time_seconds INTEGER,
    target_distance_m   DECIMAL(8,2),
    is_bodyweight       BOOLEAN DEFAULT FALSE,

    notes           TEXT,

    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    UNIQUE(section_item_id, set_number)
);

-- ============================================================================
-- PROGRAMS
-- ============================================================================

-- Training programs
CREATE TABLE programs (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name            VARCHAR(200) NOT NULL,
    description     TEXT,

    duration_weeks  INTEGER NOT NULL DEFAULT 4,
    duration_days   INTEGER DEFAULT 0,

    total_workout_days INTEGER DEFAULT 0,
    total_rest_days    INTEGER DEFAULT 0,

    is_active       BOOLEAN DEFAULT FALSE,
    is_archived     BOOLEAN DEFAULT FALSE,

    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Program day assignments
CREATE TYPE program_day_type AS ENUM ('workout', 'rest', 'unassigned');

CREATE TABLE program_days (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    program_id      UUID NOT NULL REFERENCES programs(id) ON DELETE CASCADE,
    day_number      INTEGER NOT NULL,
    day_type        program_day_type NOT NULL DEFAULT 'unassigned',

    workout_template_id UUID REFERENCES workout_templates(id),
    custom_name     VARCHAR(100),

    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    UNIQUE(program_id, day_number)
);

-- ============================================================================
-- WORKOUT SESSIONS
-- ============================================================================

CREATE TYPE workout_status AS ENUM ('in_progress', 'completed', 'abandoned');

CREATE TABLE workout_sessions (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    workout_template_id UUID REFERENCES workout_templates(id),
    program_id          UUID REFERENCES programs(id),
    program_day_number  INTEGER,

    name            VARCHAR(200),
    status          workout_status DEFAULT 'in_progress',

    started_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at    TIMESTAMP,
    duration_seconds INTEGER,

    total_sets      INTEGER DEFAULT 0,
    completed_sets  INTEGER DEFAULT 0,

    notes           TEXT,

    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Session exercises
CREATE TABLE session_exercises (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id      UUID NOT NULL REFERENCES workout_sessions(id) ON DELETE CASCADE,
    exercise_id     UUID NOT NULL REFERENCES exercises(id),

    section_item_id UUID REFERENCES section_items(id),

    display_order   INTEGER NOT NULL,
    section_name    VARCHAR(100),

    notes           TEXT,

    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Session sets
CREATE TABLE session_sets (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_exercise_id UUID NOT NULL REFERENCES session_exercises(id) ON DELETE CASCADE,
    set_number      INTEGER NOT NULL,

    weight_kg       DECIMAL(6,2),
    reps            INTEGER,
    time_seconds    INTEGER,
    distance_m      DECIMAL(8,2),

    is_bodyweight   BOOLEAN DEFAULT FALSE,
    is_completed    BOOLEAN DEFAULT FALSE,
    completed_at    TIMESTAMP,

    target_weight_kg    DECIMAL(6,2),
    target_reps         INTEGER,
    target_time_seconds INTEGER,

    rpe             DECIMAL(3,1),

    notes           TEXT,

    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    UNIQUE(session_exercise_id, set_number)
);

-- ============================================================================
-- PERSONAL RECORDS & PROGRESS TRACKING
-- ============================================================================

CREATE TABLE personal_records (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    exercise_id     UUID NOT NULL REFERENCES exercises(id),

    weight_kg       DECIMAL(6,2),
    reps            INTEGER,
    time_seconds    INTEGER,

    one_rep_max_kg  DECIMAL(6,2),
    volume          DECIMAL(10,2),

    achieved_at     DATE NOT NULL,
    session_set_id  UUID REFERENCES session_sets(id),

    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    UNIQUE(user_id, exercise_id)
);

CREATE TABLE exercise_history (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    exercise_id     UUID NOT NULL REFERENCES exercises(id),
    session_id      UUID NOT NULL REFERENCES workout_sessions(id) ON DELETE CASCADE,

    session_date    DATE NOT NULL,

    best_weight_kg  DECIMAL(6,2),
    best_reps       INTEGER,
    best_time_seconds INTEGER,

    total_sets      INTEGER,
    total_reps      INTEGER,
    total_volume_kg DECIMAL(10,2),

    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    UNIQUE(session_id, exercise_id)
);

-- ============================================================================
-- INDEXES
-- ============================================================================

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_weight_logs_user_date ON weight_logs(user_id, logged_date DESC);
CREATE INDEX idx_exercises_category ON exercises(category_id);
CREATE INDEX idx_exercises_type ON exercises(exercise_type);
CREATE INDEX idx_exercises_name ON exercises(name);
CREATE INDEX idx_workout_templates_user ON workout_templates(user_id);
CREATE INDEX idx_workout_sections_template ON workout_sections(workout_template_id, display_order);
CREATE INDEX idx_section_items_section ON section_items(section_id, display_order);
CREATE INDEX idx_programs_user ON programs(user_id);
CREATE INDEX idx_programs_active ON programs(user_id, is_active) WHERE is_active = TRUE;
CREATE INDEX idx_program_days_program ON program_days(program_id, day_number);
CREATE INDEX idx_sessions_user_date ON workout_sessions(user_id, started_at DESC);
CREATE INDEX idx_sessions_user_status ON workout_sessions(user_id, status);
CREATE INDEX idx_sessions_template ON workout_sessions(workout_template_id);
CREATE INDEX idx_session_exercises_session ON session_exercises(session_id, display_order);
CREATE INDEX idx_session_sets_exercise ON session_sets(session_exercise_id, set_number);
CREATE INDEX idx_personal_records_user ON personal_records(user_id);
CREATE INDEX idx_personal_records_user_exercise ON personal_records(user_id, exercise_id);
CREATE INDEX idx_exercise_history_user_exercise_date ON exercise_history(user_id, exercise_id, session_date DESC);
CREATE INDEX idx_exercise_history_user_date ON exercise_history(user_id, session_date DESC);

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin

DROP INDEX IF EXISTS idx_exercise_history_user_date;
DROP INDEX IF EXISTS idx_exercise_history_user_exercise_date;
DROP INDEX IF EXISTS idx_personal_records_user_exercise;
DROP INDEX IF EXISTS idx_personal_records_user;
DROP INDEX IF EXISTS idx_session_sets_exercise;
DROP INDEX IF EXISTS idx_session_exercises_session;
DROP INDEX IF EXISTS idx_sessions_template;
DROP INDEX IF EXISTS idx_sessions_user_status;
DROP INDEX IF EXISTS idx_sessions_user_date;
DROP INDEX IF EXISTS idx_program_days_program;
DROP INDEX IF EXISTS idx_programs_active;
DROP INDEX IF EXISTS idx_programs_user;
DROP INDEX IF EXISTS idx_section_items_section;
DROP INDEX IF EXISTS idx_workout_sections_template;
DROP INDEX IF EXISTS idx_workout_templates_user;
DROP INDEX IF EXISTS idx_exercises_name;
DROP INDEX IF EXISTS idx_exercises_type;
DROP INDEX IF EXISTS idx_exercises_category;
DROP INDEX IF EXISTS idx_weight_logs_user_date;
DROP INDEX IF EXISTS idx_users_email;

DROP TABLE IF EXISTS exercise_history;
DROP TABLE IF EXISTS personal_records;
DROP TABLE IF EXISTS session_sets;
DROP TABLE IF EXISTS session_exercises;
DROP TABLE IF EXISTS workout_sessions;
DROP TABLE IF EXISTS program_days;
DROP TABLE IF EXISTS programs;
DROP TABLE IF EXISTS exercise_target_sets;
DROP TABLE IF EXISTS section_items;
DROP TABLE IF EXISTS workout_sections;
DROP TABLE IF EXISTS workout_templates;
DROP TABLE IF EXISTS exercises;
DROP TABLE IF EXISTS exercise_categories;
DROP TABLE IF EXISTS weight_logs;
DROP TABLE IF EXISTS users;

DROP TYPE IF EXISTS workout_status;
DROP TYPE IF EXISTS program_day_type;
DROP TYPE IF EXISTS section_item_type;
DROP TYPE IF EXISTS exercise_type;

-- +goose StatementEnd
