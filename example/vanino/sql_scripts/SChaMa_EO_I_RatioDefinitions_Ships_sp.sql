
-- ==================================================================
-- Author:		NY
-- Create date: 30.11.2020
-- Project:		SChaMa - Vanino
-- Description:	Filling EO_I_RatioDefinitions Obj_name=Ships
-- ================================================================
CREATE OR REPLACE PROCEDURE SChaMa_EO_I_RatioDefinitions_Ships_sp(ConfigId INT)
LANGUAGE plpgsql
AS $$
BEGIN

    DELETE FROM T_EO_I_RatioDefinitions
    WHERE _ScenarioID = ConfigId AND ObjectName = 'Ships';

    -- Specific quality limits in Ratio Definition with obj_name = 'Ships'
    INSERT INTO T_EO_I_RatioDefinitions
        (_ScenarioID,
         ObjectName,
         Location,
         RatioName,
         Numerator,
         Denominator,
         ConstrainFlowIn,
         MinRatio,
         MaxRatio)
    SELECT
        ia._ScenarioID,
        ia.ObjectName,
        ia.Location,
        CONCAT(RTRIM(ia.Material), '|', 'Ratio'),
        ia.Material, -- только качетсва
        get_part_from_to_code(ia.Material, 1, 4), -- берем только для [Ves01|PANEMORFI|1|1] что в свою очеред связано напрямую с Loc
        'Hard',
        qr.ValueMin,
        qr.ValueMax
    FROM
        T_EO_I_InventoryActivity ia
        JOIN T_EO_S_SalesActivity sa ON sa._ScenarioID = ia._ScenarioID
                                      AND sa.ItemDescription = ia.Material -- только качества
        JOIN T_QualityRestrictions qr ON qr.VesselId = CAST(sa.Tag1 AS INT) -- в SalesActivity tag1 индекс судна
                                       AND qr.QltCharacteristicId = CAST(sa.Tag2 AS INT) -- в SalesActivity tag индекс качества
    WHERE
        ia._ScenarioID = ConfigId
        AND ia.ObjectName = 'Ships'
        AND COALESCE(get_part_from_to_code(ia.Material, 5, 5), '') != '' -- из IA берем Material только качетсва (можно не делать это условие)
        AND NOT (qr.ValueMin = 0 AND qr.ValueMax = 10000); -- если 0 или 10000 качество не важно

END;
$$;