-- +goose Up
-- +goose StatementBegin

-- Drop the legacy day-number program schema. Pre-launch: we destroy data.
DROP INDEX IF EXISTS idx_program_days_program;
DROP TABLE IF EXISTS program_days;

ALTER TABLE programs
    DROP COLUMN IF EXISTS duration_days,
    DROP COLUMN IF EXISTS total_workout_days,
    DROP COLUMN IF EXISTS total_rest_days,
    DROP COLUMN IF EXISTS started_at,
    ADD COLUMN start_date DATE NOT NULL DEFAULT CURRENT_DATE;

-- workout_sessions no longer carries an ordinal program_day_number
ALTER TABLE workout_sessions
    DROP COLUMN IF EXISTS program_day_number;

DROP TYPE IF EXISTS program_day_type;

-- New: each program has 1+ workouts, each assigned to a set of weekdays.
-- days_of_week stores ISO weekday ints (Monday=1..Sunday=7).
CREATE TABLE program_workouts (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    program_id          UUID NOT NULL REFERENCES programs(id) ON DELETE CASCADE,
    workout_template_id UUID NOT NULL REFERENCES workout_templates(id) ON DELETE CASCADE,
    days_of_week        SMALLINT[] NOT NULL,
    display_order       INTEGER NOT NULL,
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    UNIQUE(program_id, display_order),
    CHECK (array_length(days_of_week, 1) >= 1),
    CHECK (days_of_week <@ ARRAY[1,2,3,4,5,6,7]::SMALLINT[])
);

CREATE INDEX idx_program_workouts_program ON program_workouts(program_id, display_order);
CREATE INDEX idx_program_workouts_template ON program_workouts(workout_template_id);

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin

DROP INDEX IF EXISTS idx_program_workouts_template;
DROP INDEX IF EXISTS idx_program_workouts_program;
DROP TABLE IF EXISTS program_workouts;

CREATE TYPE program_day_type AS ENUM ('workout', 'rest', 'unassigned');

ALTER TABLE workout_sessions
    ADD COLUMN program_day_number INTEGER;

ALTER TABLE programs
    DROP COLUMN IF EXISTS start_date,
    ADD COLUMN started_at TIMESTAMP,
    ADD COLUMN total_rest_days INTEGER DEFAULT 0,
    ADD COLUMN total_workout_days INTEGER DEFAULT 0,
    ADD COLUMN duration_days INTEGER DEFAULT 0;

CREATE TABLE program_days (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    program_id          UUID NOT NULL REFERENCES programs(id) ON DELETE CASCADE,
    day_number          INTEGER NOT NULL,
    day_type            program_day_type NOT NULL DEFAULT 'unassigned',
    workout_template_id UUID REFERENCES workout_templates(id),
    custom_name         VARCHAR(100),
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(program_id, day_number)
);
CREATE INDEX idx_program_days_program ON program_days(program_id, day_number);

-- +goose StatementEnd
