-- +goose Up
-- +goose StatementBegin

-- Seed exercise categories
INSERT INTO exercise_categories (id, name, display_order) VALUES
    ('11111111-1111-1111-1111-111111111101', 'Chest', 1),
    ('11111111-1111-1111-1111-111111111102', 'Back', 2),
    ('11111111-1111-1111-1111-111111111103', 'Shoulders', 3),
    ('11111111-1111-1111-1111-111111111104', 'Arms', 4),
    ('11111111-1111-1111-1111-111111111105', 'Legs', 5),
    ('11111111-1111-1111-1111-111111111106', 'Core', 6),
    ('11111111-1111-1111-1111-111111111107', 'Cardio', 7),
    ('11111111-1111-1111-1111-111111111108', 'Full Body', 8);

-- Seed system exercises
INSERT INTO exercises (name, category_id, exercise_type, is_system, description) VALUES
    -- Chest
    ('Bench Press', '11111111-1111-1111-1111-111111111101', 'weight_reps', TRUE, 'Lie on bench, grip bar slightly wider than shoulder width, lower to chest and press up.'),
    ('Incline Bench Press', '11111111-1111-1111-1111-111111111101', 'weight_reps', TRUE, 'Bench set to 30-45 degrees, press from upper chest.'),
    ('Dumbbell Flyes', '11111111-1111-1111-1111-111111111101', 'weight_reps', TRUE, 'Lie on bench, arms extended, lower weights in arc to sides.'),
    ('Push-ups', '11111111-1111-1111-1111-111111111101', 'bodyweight_reps', TRUE, 'Hands shoulder-width apart, lower chest to floor and push up.'),
    ('Cable Crossover', '11111111-1111-1111-1111-111111111101', 'weight_reps', TRUE, 'Stand between cables, bring handles together in front of chest.'),

    -- Back
    ('Deadlift', '11111111-1111-1111-1111-111111111102', 'weight_reps', TRUE, 'Feet hip-width, grip bar, drive through heels keeping back straight.'),
    ('Barbell Rows', '11111111-1111-1111-1111-111111111102', 'weight_reps', TRUE, 'Bend at hips, pull bar to lower chest, squeeze shoulder blades.'),
    ('Dumbbell Rows', '11111111-1111-1111-1111-111111111102', 'weight_reps', TRUE, 'Keep back flat, pull to hip level.'),
    ('Pull-ups', '11111111-1111-1111-1111-111111111102', 'bodyweight_reps', TRUE, 'Full range of motion, chin over bar.'),
    ('Lat Pulldown', '11111111-1111-1111-1111-111111111102', 'weight_reps', TRUE, 'Wide grip, pull bar to upper chest, squeeze lats.'),
    ('Seated Cable Row', '11111111-1111-1111-1111-111111111102', 'weight_reps', TRUE, 'Sit upright, pull handle to abdomen, squeeze back.'),

    -- Shoulders
    ('Overhead Press', '11111111-1111-1111-1111-111111111103', 'weight_reps', TRUE, 'Press bar from shoulders to overhead lockout.'),
    ('Lateral Raises', '11111111-1111-1111-1111-111111111103', 'weight_reps', TRUE, 'Raise dumbbells to sides until parallel with floor.'),
    ('Front Raises', '11111111-1111-1111-1111-111111111103', 'weight_reps', TRUE, 'Raise dumbbells in front to shoulder height.'),
    ('Face Pulls', '11111111-1111-1111-1111-111111111103', 'weight_reps', TRUE, 'Pull rope to face, external rotate at top.'),
    ('Arnold Press', '11111111-1111-1111-1111-111111111103', 'weight_reps', TRUE, 'Start palms facing you, rotate and press overhead.'),

    -- Arms
    ('Bicep Curls', '11111111-1111-1111-1111-111111111104', 'weight_reps', TRUE, 'Keep elbows stationary, curl weight to shoulders.'),
    ('Hammer Curls', '11111111-1111-1111-1111-111111111104', 'weight_reps', TRUE, 'Neutral grip curl, works brachialis.'),
    ('Tricep Pushdown', '11111111-1111-1111-1111-111111111104', 'weight_reps', TRUE, 'Push cable down, lock out elbows.'),
    ('Skull Crushers', '11111111-1111-1111-1111-111111111104', 'weight_reps', TRUE, 'Lower bar to forehead, extend arms.'),
    ('Dips', '11111111-1111-1111-1111-111111111104', 'bodyweight_reps', TRUE, 'Lower until upper arms parallel, press up.'),

    -- Legs
    ('Barbell Squats', '11111111-1111-1111-1111-111111111105', 'weight_reps', TRUE, 'Focus on deep squatting, keep back straight.'),
    ('Leg Press', '11111111-1111-1111-1111-111111111105', 'weight_reps', TRUE, 'Position feet shoulder-width apart on the platform.'),
    ('Romanian Deadlift', '11111111-1111-1111-1111-111111111105', 'weight_reps', TRUE, 'Hip hinge with slight knee bend, feel hamstring stretch.'),
    ('Lunges', '11111111-1111-1111-1111-111111111105', 'weight_reps', TRUE, 'Step forward, lower until both knees at 90 degrees.'),
    ('Leg Curls', '11111111-1111-1111-1111-111111111105', 'weight_reps', TRUE, 'Curl weight towards glutes, squeeze hamstrings.'),
    ('Leg Extensions', '11111111-1111-1111-1111-111111111105', 'weight_reps', TRUE, 'Extend legs fully, squeeze quads at top.'),
    ('Calf Raises', '11111111-1111-1111-1111-111111111105', 'weight_reps', TRUE, 'Rise onto toes, pause at top, lower with control.'),

    -- Core
    ('Plank', '11111111-1111-1111-1111-111111111106', 'time', TRUE, 'Keep core tight, body in straight line.'),
    ('Russian Twists', '11111111-1111-1111-1111-111111111106', 'weight_reps', TRUE, 'Rotate torso side to side with weight.'),
    ('Hanging Leg Raises', '11111111-1111-1111-1111-111111111106', 'bodyweight_reps', TRUE, 'Hang from bar, raise legs to parallel.'),
    ('Ab Crunches', '11111111-1111-1111-1111-111111111106', 'bodyweight_reps', TRUE, 'Curl shoulders towards hips, squeeze abs.'),
    ('Dead Bug', '11111111-1111-1111-1111-111111111106', 'bodyweight_reps', TRUE, 'Opposite arm/leg extension while maintaining core stability.'),

    -- Cardio / Warm-up
    ('Jumping Jacks', '11111111-1111-1111-1111-111111111107', 'cardio', TRUE, 'Jump while spreading legs and raising arms overhead.'),
    ('Arm Circles', '11111111-1111-1111-1111-111111111107', 'cardio', TRUE, 'Rotate arms in circles to warm up shoulders.'),
    ('High Knees', '11111111-1111-1111-1111-111111111107', 'cardio', TRUE, 'Run in place bringing knees to waist height.'),
    ('Burpees', '11111111-1111-1111-1111-111111111107', 'bodyweight_reps', TRUE, 'Squat, jump back to plank, push-up, jump forward, jump up.'),
    ('Mountain Climbers', '11111111-1111-1111-1111-111111111107', 'time', TRUE, 'Plank position, alternate driving knees to chest.');

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin

DELETE FROM exercises WHERE is_system = TRUE;
DELETE FROM exercise_categories WHERE id IN (
    '11111111-1111-1111-1111-111111111101',
    '11111111-1111-1111-1111-111111111102',
    '11111111-1111-1111-1111-111111111103',
    '11111111-1111-1111-1111-111111111104',
    '11111111-1111-1111-1111-111111111105',
    '11111111-1111-1111-1111-111111111106',
    '11111111-1111-1111-1111-111111111107',
    '11111111-1111-1111-1111-111111111108'
);

-- +goose StatementEnd
