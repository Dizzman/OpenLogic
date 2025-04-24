-- create_t_vessels.sql
CREATE TABLE IF NOT EXISTS T_Vessels (
    Id SERIAL PRIMARY KEY,
    _ScenarioID INT,
    VesselCode VARCHAR,
    DaysBeforeArrival INT,
    VesselName VARCHAR,
    Customer VARCHAR,
    Grade VARCHAR,
    Demurrage NUMERIC,
    MaxLoadSpeedContract FLOAT,
    MaxLoadSpeedReal FLOAT,
    VolumeMin FLOAT,
    VolumeMax FLOAT,
    Contract VARCHAR,
    FIX NUMERIC,
    Days NUMERIC,
    Basis VARCHAR,
    Maxshift INT
);