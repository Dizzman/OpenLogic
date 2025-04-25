-- =============================================
-- Author:		NY
-- Create date: 30.11.2020
-- Project:		SChaMa - Vanino
-- Description:	Filling EO_E_LocationDefinitions with all locations
-- =============================================
CREATE OR REPLACE PROCEDURE SChaMa_EO_E_LocationDefinitions_sp(ConfigId INT)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Удаляем старые записи для данного конфига
    DELETE FROM T_EO_E_LocationDefinitions
    WHERE _ScenarioID = ConfigId;

    -- Локации в "Sales"
    INSERT INTO T_EO_E_LocationDefinitions
        (_ScenarioID, Location, Tag1, Tag2, DecisionSwitch)
    SELECT DISTINCT
        av._ScenarioID,
        RTRIM(av.EO_Vessel) || '|Loc|' || RTRIM(tpd.TimePeriod),
        'Sales',
        av.EO_Vessel,
        'Set by Period'
    FROM
        T_EOtemp_ActiveVessel av
        JOIN T_EO_E_TimePeriodDefinitions tpd ON av._ScenarioID = tpd._ScenarioID
        JOIN T_Configuration c ON av._ScenarioID = c.id
    WHERE
        av._ScenarioID = ConfigId
        AND av.DayOfStart <= tpd.PeriodIndex
        AND c.NumberOfDays + 2 + c.NumberOfWeekPeriods * 7 +
            c.NumberOf2WeekPeriods * 14 - av.DaysToLoad >= tpd.PeriodIndex
        AND tpd.PeriodIndex <= av.DayOfStart + av.MaxShiftDays;

    -- Локации в "Ships"
    INSERT INTO T_EO_E_LocationDefinitions
        (_ScenarioID, Location, Tag1, Tag2, DecisionSwitch, Attribute1)
    SELECT
        av._ScenarioID,
        RTRIM(av.EO_Vessel) || '|Loc',
        'Ships',
        av.EO_Vessel,
        'Set by Period',
        RTRIM(av.EO_Vessel) || '|Loc'
    FROM
        T_EOtemp_ActiveVessel av
    WHERE
        av._ScenarioID = ConfigId;

    -- Локации в "Incoming" и "Piles"
    INSERT INTO T_EO_E_LocationDefinitions
        (_ScenarioID, Location, Tag1, DecisionSwitch)
    VALUES
        (ConfigId, 'Piles', 'Piles', 'Open');

    -- Локации в "Incoming" для Day items
    INSERT INTO T_EO_E_LocationDefinitions
        (_ScenarioID, Location, Tag1, DecisionSwitch)
    VALUES
        (ConfigId, 'Days', 'Days', 'Open');
END;
$$