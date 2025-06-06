CREATE TABLE IF NOT EXISTS T_Scenarios (
    _ScenarioID SERIAL PRIMARY KEY,
    project_name VARCHAR(255) NOT NULL,
    scenario_name VARCHAR(255) NOT NULL UNIQUE,
    is_active BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    description TEXT
);