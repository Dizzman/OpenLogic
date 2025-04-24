CREATE TABLE IF NOT EXISTS T_QltCharacteristics (
    Id SERIAL PRIMARY KEY,
    _ScenarioID INTEGER NOT NULL,
    QualityCode VARCHAR(20),
    QualityName VARCHAR(510)
);