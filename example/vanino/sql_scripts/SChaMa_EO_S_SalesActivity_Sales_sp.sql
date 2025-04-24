-- ==================================================================
-- Author:      NY
-- Create date: 30.11.2020
-- Project:     SChaMa - Vanino
-- Description: Filling EO_S_SalesActivity Obj_name=Sales
-- ==================================================================
CREATE OR REPLACE PROCEDURE schama_eo_s_salesactivity_sales_sp(ConfigId INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Delete existing data for specified ConfigId
    DELETE FROM T_EO_S_SalesActivity
    WHERE _ScenarioID = ConfigId
    AND ObjectName = 'Sales';

    -- Vessels with tonnage in Sales Activity "Sales"
    INSERT INTO T_EO_S_SalesActivity
        (_ScenarioID,
         ObjectName,
         Location,
         ItemDescription,
         Attribute1,
         Attribute2,
         MaxUnitsPerPeriod,
         VariableType,
         Tag1)
    SELECT
        av._ScenarioID,
        'Sales',
        ld.Location,
        RTRIM(av.EO_Vessel),
        ad1.Attribute,
        ld.Location || '|Const',
        av.MaxSpeed_kT,
        'Continuous',
        av.vesselid
    FROM
        T_EOtemp_ActiveVessel av
        JOIN T_EO_E_LocationDefinitions ld ON ld._ScenarioID = av._ScenarioID
                                            AND ld.Tag1 = 'Sales'
                                            AND ld.Tag2 = av.EO_Vessel
        JOIN T_EO_A_AttributeDefinitions ad1 ON ad1._ScenarioID = av._ScenarioID
                                               AND ad1.Tag1 = 'MinMax'
                                               AND ad1.Tag2 = av.EO_Vessel
    WHERE
        av._ScenarioID = ConfigId;

    -- Day Items in Sales Activity "Sales"
    INSERT INTO T_EO_S_SalesActivity
        (_ScenarioID,
         ObjectName,
         Location,
         ItemDescription,
         Attribute2,
         Attribute3,
         Attribute4,
         MaxUnitsPerPeriod,
         VariableType,
         PricePerUnit,
         Tag1)
    SELECT
        av._ScenarioID,
        'Sales',
        ld.Location,
        pa.ItemDescription,
        ld.Location || '|Const',
        RTRIM(av.EO_Vessel) || '|DtL',
        CASE
            WHEN COALESCE(get_part_from_to_code(pa.ItemDescription, 2, 2), '1') = COALESCE(get_part_from_to_code(ld.Location, 6, 6), '2')
            THEN RTRIM(av.EO_Vessel) || '|Day|' || get_part_from_to_code(ld.Location, 6, 6)
            ELSE NULL
        END,
        1,
        'Integer',
        -av.Demur_kS * FLOOR((CAST(get_part_from_to_code(pa.ItemDescription, 2, 2) AS INT) - av.DayOfStart) / av.DaysToLoad),
        av.VesselId
    FROM
        T_EOtemp_ActiveVessel av
        JOIN T_EO_E_LocationDefinitions ld ON ld._ScenarioID = av._ScenarioID
                                            AND ld.Tag1 = 'Sales'
                                            AND ld.Tag2 = av.EO_Vessel
        JOIN T_EO_P_PurchaseActivity pa ON pa._ScenarioID = av._ScenarioID
                                         AND pa.ObjectName = 'Incoming'
                                         AND get_part_from_to_code(pa.ItemDescription, 1, 1) = 'Day'
    WHERE
        av._ScenarioID = ConfigId
        AND CAST(get_part_from_to_code(pa.ItemDescription, 2, 2) AS INT) >= CAST(get_part_from_to_code(ld.Location, 6, 6) AS INT)
        AND CAST(get_part_from_to_code(pa.ItemDescription, 2, 2) AS INT) <
            CAST(get_part_from_to_code(ld.Location, 6, 6) AS INT) + av.DaysToLoad;

    -- Vessels with Quality in Sales Activity "Sales"
    INSERT INTO T_EO_S_SalesActivity
        (_ScenarioID,
         ObjectName,
         Location,
         ItemDescription,
         VariableType,
         tag1,
         tag2)
    SELECT
        av._ScenarioID,
        'Sales',
        ld.Location,
        CONCAT(RTRIM(av.EO_Vessel), '|', RTRIM(qc.QualityCode), '|', RTRIM(qc.QualityName)),
        'Continuous',
        qr.VesselId,
        qr.QltCharacteristicId
    FROM
        T_EOtemp_ActiveVessel av
        JOIN T_EO_E_LocationDefinitions ld ON ld._ScenarioID= av._ScenarioID
                                            AND ld.Tag1 = 'Ships'
                                            AND ld.Tag2 = av.EO_Vessel
        CROSS JOIN (SELECT DISTINCT
                        QltCharacteristicId,
                        VesselId
                    FROM T_QualityRestrictions) qr
        JOIN T_QltCharacteristics qc ON qc.Id = qr.QltCharacteristicId
                                      AND qc._ScenarioID = av._ScenarioID
    WHERE
        av._ScenarioID = ConfigId
        AND qr.VesselId = av.VesselId;
END;
$$;