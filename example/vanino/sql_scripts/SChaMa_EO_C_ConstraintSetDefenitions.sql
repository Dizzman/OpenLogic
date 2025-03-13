-- schema_eo_c_constraintsetdefinitions_sp.sql
CREATE OR REPLACE PROCEDURE schema_eo_c_constraintsetdefinitions_sp(ConfigId INT)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Удаляем старые данные для указанного ConfigId
    DELETE FROM EO_C_ConstraintSetDefinitions
    WHERE _ScenarioID = ConfigId;

    -- Вставляем новые данные для активных судов
    INSERT INTO EO_C_ConstraintSetDefinitions
        (_ScenarioID, ConstraintSet, MinTotalActiveSetElements, MaxTotalActiveSetElements, ConstraintSetType)
    SELECT
        configid,
        EO_Vessel,
        1,
        1,
        'All Periods'
    FROM
        EOtemp_ActiveVessel
    WHERE
        _ScenarioID = ConfigId;
END;
$$;