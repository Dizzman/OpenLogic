-- =============================================
-- Author:		NY
-- Create date: 30.11.2020
-- Project:		SChaMa - Vanino
-- Description:	Filling EOtemp_ActiveVessel with Vessels having FIX = 0
-- =============================================
CREATE OR REPLACE PROCEDURE SChaMa_EOtemp_ActiveVessel_sp(p_ConfigId INTEGER)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Delete existing records for the given ConfigId
    DELETE FROM T_EOtemp_ActiveVessel
    WHERE _ScenarioID = 1;

    -- Insert active vessels with FIX = 0
    INSERT INTO T_EOtemp_ActiveVessel (
        _ScenarioID, VesselId, VesselCode, EO_Vessel,
        DiscreteDaysVes, DayOfStart, DaysToLoad,
        Demur_kS, MaxSpeed_kT, VolMin_kT, VolMax_kT,
        MaxShiftDays
    )
    SELECT
        v._ScenarioID, v.Id, v.VesselCode,
        TRIM(TRAILING FROM (v.VesselCode || '|' || v.VesselName || '|' || CAST((v.DaysBeforeArrival + 1) AS VARCHAR(3)) || '|' || CAST(CEILING(v.VolumeMax/v.MaxLoadSpeedReal) AS VARCHAR(1)))),
        0,
        v.DaysBeforeArrival + 1,
        CEILING(v.VolumeMax/v.MaxLoadSpeedReal),
        v.Demurrage/1000,
        v.MaxLoadSpeedReal/1000,
        v.VolumeMin/1000,
        v.VolumeMax/1000,
        COALESCE(v.Maxshift, c.Maxshiftdefault)
    FROM
        T_Vessels v
    JOIN T_Configuration c ON c.ID = v._ScenarioID
    WHERE
        v._ScenarioID = 1
        AND v.FIX = 0
        AND (v.DaysBeforeArrival + CEILING(v.VolumeMax/v.MaxLoadSpeedReal)) <= (c.NumberOfDays + 1 + c.NumberOfWeekPeriods * 7 + c.NumberOf2WeekPeriods * 14);

END;
$$;