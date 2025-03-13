-- create_t_vessels.sql
CREATE TABLE IF NOT EXISTS T_Vessels (
    Id INT,
    ConfigId INT,
    VesselCode VARCHAR,
    DaysBeforeArrival INT,
    VesselName VARCHAR,
    Customer VARCHAR,
    Grade VARCHAR,
    Demurrage NUMERIC,
    MaxLoadSpeedContract NUMERIC,
    MaxLoadSpeedReal NUMERIC,
    VolumeMin NUMERIC,
    VolumeMax NUMERIC,
    Contract VARCHAR,
    FIX BOOLEAN,
    Days NUMERIC,
    Basis VARCHAR,
    Maxshift INT
);