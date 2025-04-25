-- create_configuration.sql
CREATE TABLE IF NOT EXISTS T_Configuration (
    ID SERIAL PRIMARY KEY,
    NumberOfPiles INT,
    NumberOfVessels INT,
    NumberOfDiscreteDays INT,
    NumberOfQCs INT,
    NumberOfDays INT,
    ConfirmedDays INT,
    DVZHDDays INT,
    FarawayDays INT,
    PlannedDays INT,
    NumberOfWeekPeriods INT,
    NumberOf2WeekPeriods INT,
    Maxshiftdefault INT
);