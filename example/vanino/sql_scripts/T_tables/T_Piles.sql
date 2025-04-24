CREATE TABLE IF NOT EXISTS T_Piles (
    Id SERIAL PRIMARY KEY,
    _ScenarioID INTEGER NOT NULL,
    PileCode VARCHAR(255),
    PileName VARCHAR(255),
    MinStock FLOAT,
    StockYard FLOAT,
    OnBoard FLOAT,
    ConfirmedVolume FLOAT,
    ConfirmedDays FLOAT,
    DVZHDVolume FLOAT,
    DVZHDDays FLOAT,
    FarawayVolume FLOAT,
    FarawayDays FLOAT,
    PlannedVolume FLOAT,
    PlannedDays FLOAT,
    LongRunVolume FLOAT,
    LongRunDays FLOAT
);