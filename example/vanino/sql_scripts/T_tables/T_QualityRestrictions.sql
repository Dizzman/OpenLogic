CREATE TABLE IF NOT EXISTS T_QualityRestrictions (
    _ScenarioID INTEGER NOT NULL,
    VesselId INTEGER NOT NULL,
    QltCharacteristicId INTEGER NOT NULL,
    ValueMin FLOAT,
    ValueMax FLOAT
);

