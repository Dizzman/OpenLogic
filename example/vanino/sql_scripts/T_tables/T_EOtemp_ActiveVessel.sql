-- create_teotemp_activevessel.sql
CREATE TABLE IF NOT EXISTS T_EOtemp_ActiveVessel (
    _ScenarioID INT,
    vesselid INT,
    vesselcode VARCHAR,
    eo_vessel VARCHAR,
    dayofstart INT,
    daystoload INT,
    discretedaysves INT,
    demur_ks NUMERIC,
    maxspeed_kt NUMERIC,
    volmin_kt NUMERIC,
    volmax_kt NUMERIC,
    maxshiftdays INT
);