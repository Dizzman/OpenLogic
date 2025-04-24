CREATE OR REPLACE PROCEDURE schama_eo_e_locationdefinitions_sp(ConfigId INT)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Удаляем старые данные для указанного ConfigId
    DELETE FROM T_EO_E_LocationDefinitions
    WHERE _ScenarioID = ConfigId;

    -- Locations in "Sales"
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
        JOIN T_Configuration c ON av._ScenarioID = c._ScenarioID
    WHERE
        av._ScenarioID = ConfigId
        AND av.DayOfStart <= tpd.PeriodIndex
        AND c.NumberOfDays + 2 + c.NumberOfWeekPeriods*7 + c.NumberOf2WeekPeriods*14 - av.DaysToLoad >= tpd.PeriodIndex
        AND tpd.PeriodIndex <= av.DayOfStart + av.MaxShiftDays;

    -- Locations in "Ships"
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

    -- Locations in "Incoming" and "Piles"
    INSERT INTO T_EO_E_LocationDefinitions
        (_ScenarioID, Location, Tag1, DecisionSwitch)
    VALUES
        (ConfigId, 'Piles', 'Piles', 'Open');

    -- Locations in "Incoming" for Day items
    INSERT INTO T_EO_E_LocationDefinitions
        (_ScenarioID, Location, Tag1, DecisionSwitch)
    VALUES
        (ConfigId, 'Days', 'Days', 'Open');
END;
$$;