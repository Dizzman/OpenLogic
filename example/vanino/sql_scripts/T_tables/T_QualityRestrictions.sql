CREATE TABLE IF NOT EXISTS T_QualityRestrictions (
    _ScenarioID INTNOT NULL,
    VesselId INT NOT NULL,
    QltCharacteristicId INT NOT NULL,
    ValueMin FLOAT,
    ValueMax FLOAT
);

