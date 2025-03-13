CREATE OR REPLACE PROCEDURE EO_E_LocationDefinitions_sp(config_id INT)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Удаляем записи для указанного ConfigId
    DELETE FROM eo_e_locationdefinitions
    WHERE _ScenarioID = config_id;

    -- Локации в "Sales"
    INSERT INTO eo_e_locationdefinitions
        (_ScenarioID, location, tag1, tag2, decisionswitch)
    SELECT DISTINCT
        av._ScenarioID,
        RTRIM(av.eo_vessel) || '|Loc|' || RTRIM(tpd.timeperiod),
        'Sales',
        av.eo_vessel,
        'Set by Period'
    FROM
        T_EOtemp_ActiveVessel av
    JOIN
        eo_e_timeperioddefinitions tpd ON av._ScenarioID = tpd._ScenarioID
    JOIN
        configuration c ON av._ScenarioID = c.ID
    WHERE
        av._ScenarioID = config_id
        AND av.dayofstart <= tpd.periodindex
        AND c.numberofdays + 2 - av.daystoload >= tpd.periodindex;

    -- Локации в "Ships"
    INSERT INTO eo_e_locationdefinitions
        (_ScenarioID, location, tag1, tag2, decisionswitch, attribute1)
    SELECT
        av._ScenarioID,
        RTRIM(av.eo_vessel) || '|Loc',
        'Ships',
        av.eo_vessel,
        'Set by Period',
        RTRIM(av.eo_vessel) || '|Loc'
    FROM
        T_EOtemp_ActiveVessel av
    WHERE
        av._ScenarioID = config_id;

    -- Локации в "Incoming" и "Piles"
    INSERT INTO eo_e_locationdefinitions
        (_ScenarioID, location, tag1, decisionswitch)
    VALUES
        (config_id, 'Piles', 'Piles', 'Open');

    -- Локации в "Incoming" для Day items
    INSERT INTO eo_e_locationdefinitions
        (_ScenarioID, location, tag1, decisionswitch)
    VALUES
        (config_id, 'Days', 'Days', 'Open');
END;
$$;