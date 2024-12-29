-- =============================================
-- Author:        NY
-- Create date:   23.10.2017
-- Description:   Filling EOtemp_ActiveVessel with Vessels having FIX = 0
-- Change #1
-- Change date:   11.12.2017
-- Description:   New field 'DiscreteDaysVes' in table
-- =============================================
CREATE OR REPLACE FUNCTION EOtemp_ActiveVessel_sp(ScenarioID INT)
RETURNS VOID AS $$
BEGIN
    DELETE FROM T_EOtemp_ActiveVessel
    WHERE _ScenarioID = ScenarioID;

    INSERT INTO T_EOtemp_ActiveVessel
        (_ScenarioID, VesselId,
         VesselCode, EO_Vessel,
         DiscreteDaysVes,
         DayOfStart, DaysToLoad,
         Demur_kS, MaxSpeed_kT,
         VolMin_kT, VolMax_kT,maxshiftdays )
    SELECT
        ScenarioID,
        Id,
        VesselCode,
        VesselCode || '|' || VesselName || '|' || CAST((DaysBeforeArrival + 1) AS VARCHAR) || '|' || CAST(CEIL(VolumeMax / MaxLoadSpeedReal) AS VARCHAR),
        0,
        DaysBeforeArrival + 1,
        CEIL(VolumeMax / MaxLoadSpeedReal),
        Demurrage / 1000,
        MaxLoadSpeedReal / 1000,
        VolumeMin / 1000,
        VolumeMax / 1000,
        Maxshift
    FROM
        T_Vessels
    WHERE
        _ScenarioID= ScenarioID
        AND FIX = 0;
END;
$$ LANGUAGE plpgsql;
