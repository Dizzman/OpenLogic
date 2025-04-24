-- create_teotemp_activevessel.sql
CREATE TABLE IF NOT EXISTS T_EOtemp_ActiveVessel (
    _ScenarioID INT,
    vesselid INT,
    vesselcode VARCHAR,
    eo_vessel VARCHAR,
    dayofstart INT,
    daystoload INT,
    discretedaysves INT,
    demur_ks FLOAT,
    maxspeed_kt FLOAT,
    volmin_kt FLOAT,
    volmax_kt FLOAT,
    maxshiftdays INT
);