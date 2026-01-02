-- +goose Up
CREATE TABLE session_rest_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID NOT NULL REFERENCES workout_sessions(id) ON DELETE CASCADE,
    section_item_id UUID REFERENCES section_items(id),
    display_order INTEGER NOT NULL,
    section_name VARCHAR(100),
    rest_duration_seconds INTEGER NOT NULL,
    is_completed BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_session_rest_items_session ON session_rest_items(session_id);

-- +goose Down
DROP TABLE session_rest_items;
