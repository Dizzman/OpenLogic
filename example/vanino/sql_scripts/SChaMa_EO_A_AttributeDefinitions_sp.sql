-- =============================================
-- Author:      NY
-- Create date: 30.11.2020
-- Project:     SChaMa - Vanino
-- Description: Filling EO_A_AttributeDefinitions with all attributes
-- =============================================
CREATE OR REPLACE PROCEDURE schama_eo_a_attributedefinitions_sp(
    IN ConfigId INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Delete existing records for this ConfigId
    DELETE FROM t_eo_a_attributedefinitions
    WHERE _ScenarioID = ConfigId;

    -- Locations in "Ships"
    INSERT INTO t_eo_a_attributedefinitions
        (_ScenarioID, attribute, tag1, tag2, attributetype, objectclassappliedto, maxtotalunitsorvalue)
    SELECT
        _ScenarioID,
        RTRIM(eo_vessel) || '|Loc',
        'Loc',
        eo_vessel,
        'Activity',
        'Location', -- ограничеваем Location
        daystoload -- вычисляется количество дней огрузки в SChaMa_EOtemp_ActiveVessel_sp как MaxVolume/скорость  - OK
    FROM
        t_eotemp_activevessel
    WHERE
        _ScenarioID = ConfigId;

    -- Constraints in "Sales"
    INSERT INTO t_eo_a_attributedefinitions
        (_ScenarioID, attribute, tag1, tag2, attributetype, objectclassappliedto, constraintset)
    SELECT
        _ScenarioID,
        location || '|Const',
        'Constraint',
        tag2,
        'Activity',
        'Sales',
        tag2
    FROM
        t_eo_e_locationdefinitions
    WHERE
        _ScenarioID = ConfigId
        AND tag1 = 'Sales';

    -- Min-Max Volumes in "Sales"
    INSERT INTO t_eo_a_attributedefinitions
        (_ScenarioID, attribute, tag1, tag2, attributetype, objectclassappliedto, mintotalunitsorvalue, maxtotalunitsorvalue)
    SELECT
        _ScenarioID,
        RTRIM(eo_vessel) || '|MinMax',
        'MinMax',
        eo_vessel,
        'Activity',
        'Sales',
        volmin_kt,
        volmax_kt
    FROM
        t_eotemp_activevessel
    WHERE
        _ScenarioID = ConfigId;

    -- Days to Load in "Sales"
    INSERT INTO t_eo_a_attributedefinitions
        (_ScenarioID, attribute, tag1, tag2, attributetype, objectclassappliedto, mintotalunitsorvalue, maxtotalunitsorvalue)
    SELECT
        _ScenarioID,
        RTRIM(eo_vessel) || '|DtL',
        'DtL',
        eo_vessel,
        'Activity',
        'Sales',
        daystoload,
        daystoload
    FROM
        t_eotemp_activevessel
    WHERE
        _ScenarioID = ConfigId;
END;
$$;