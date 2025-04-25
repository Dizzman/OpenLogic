-- ==================================================================
-- Author:      NY
-- Create date: 30.11.2020
-- Project:     SChaMa - Vanino
-- Description: Filling EO_ItI_ToShipmentDescription Obj_name=Piles_to_Ships
-- ================================================================
CREATE OR REPLACE PROCEDURE SChaMa_EO_ItI_ToShipmentDescription_Piles_to_Ships_sp(
    ConfigId INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Delete existing records for this config
    DELETE FROM T_EO_ItI_ToShipmentDescription
    WHERE _ScenarioID = ConfigId
          AND ObjectName = 'Piles_to_Ships';

    -- Fill EO_ItI_ToShipmentDescription for Link "Piles_to_Ships" with tonnage
    INSERT INTO T_EO_ItI_ToShipmentDescription(
        _ScenarioID,
        ObjectName,
        FromLocation,
        ToLocation,
        ShipmentDescription,
        ToMaterial,
        YieldUnitsPerShipment
    )
    SELECT
        ta._ScenarioID,
        'Piles_to_Ships',
        ta.FromLocation,
        ta.ToLocation,
        ta.ShipmentDescription,
        get_part_from_to_code(ta.ShipmentDescription, 3, 6),
        1
    FROM
        T_EO_ItI_TransferActivity ta
    WHERE
        ta._ScenarioID = ConfigId
        AND ta.ObjectName = 'Piles_to_Ships'

    UNION

    SELECT
        ta._ScenarioID,
        'Piles_to_Ships',
        ta.FromLocation,
        ta.ToLocation,
        ta.ShipmentDescription,
        CONCAT(RTRIM(get_part_from_to_code(ta.ShipmentDescription, 3, 6)), '|',
               RTRIM(qc.QualityCode), '|',
               RTRIM(qc.QualityName)),
        pq.Value
    FROM
        T_EO_ItI_TransferActivity ta
        JOIN T_PileQuality pq ON pq.PileId = CAST(ta.Tag2 AS INT)
        JOIN T_QltCharacteristics qc ON qc._ScenarioID = ta._ScenarioID  AND qc.id = pq.QualityId
    WHERE
        ta._ScenarioID= ConfigId
        AND ta.ObjectName = 'Piles_to_Ships'
        AND pq.Value > 0; -- exclude zero yield
END;
$$;