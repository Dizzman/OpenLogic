-- =============================================
-- Author:      NY
-- Create date: 30.11.2020
-- Project:     SChaMa - Vanino
-- Description: PostProcessing of EO_E_TimePeriodDefinitions for Telescope
-- =============================================
CREATE OR REPLACE PROCEDURE SChaMa_EO_PostProc_E_TimePeriodDefinitions_sp(
    ConfigId INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Create temporary table for days data
    CREATE TEMPORARY TABLE TPD_days AS
    SELECT *
    FROM T_EO_E_TimePeriodDefinitions
    WHERE _ScenarioID = ConfigId;

    -- Delete existing records for this config
    DELETE FROM T_EO_E_TimePeriodDefinitions
    WHERE _ScenarioID = ConfigId;

    -- Insert Telescoped Time Periods
    INSERT INTO T_EO_E_TimePeriodDefinitions(
        _ScenarioID,
        TimePeriod,
        Tag1,
        Tag2,
        PeriodIndex
    )
    SELECT
        ConfigId,
        Tag2,
        Tag1,
        CASE
            WHEN MIN(PeriodIndex) = MAX(PeriodIndex) THEN ''
            ELSE CONCAT(MIN(PeriodIndex)::text, '-', MAX(PeriodIndex)::text)
        END,
        MAX(PeriodIndex) as PeriodIndex
    FROM TPD_days
    GROUP BY Tag2, Tag1
    ORDER BY PeriodIndex;

    -- Clean up temporary table
    DROP TABLE IF EXISTS TPD_days;
END;
$$;