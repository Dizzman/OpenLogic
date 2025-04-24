-- schema_eo_c_constraintsetdefinitions_sp.sql
CREATE OR REPLACE PROCEDURE schama_eo_c_constraintsetdefinitions_sp(ConfigId INT)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Удаляем старые данные для указанного ConfigId
    DELETE FROM T_EO_C_ConstraintSetDefinitions
    WHERE _ScenarioID = ConfigId;

    -- Вставляем новые данные для активных судов
    INSERT INTO T_EO_C_ConstraintSetDefinitions
        (_ScenarioID, ConstraintSet, MinTotalActiveSetElements, MaxTotalActiveSetElements, ConstraintSetType)
    SELECT
        configid,
        EO_Vessel,
        1,
        1,
        'All Periods'
    FROM
        T_EOtemp_ActiveVessel
    WHERE
        _ScenarioID = ConfigId;
END;
$$;