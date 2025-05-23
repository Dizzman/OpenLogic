-- ==================================================================
-- Author:      NY
-- Create date: 30.11.2020
-- Project:     SChaMa - Vanino
-- Description: Filling EO_ItI_FromShipmentDescription Obj_name=Piles_to_Ships
-- ================================================================
CREATE OR REPLACE PROCEDURE SChaMa_EO_ItI_FromShipmentDescription_Piles_to_Ships_sp(
    ConfigId INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Delete existing records for this config
    DELETE FROM T_EO_ItI_FromShipmentDescription
    WHERE _ScenarioID = ConfigId
          AND ObjectName = 'Piles_to_Ships';

    -- Fill EO_ItI_FromShipmentDescription for Link "Piles_to_Ships"
    INSERT INTO T_EO_ItI_FromShipmentDescription(
        _ScenarioID,
        ObjectName,
        FromLocation,
        ToLocation,
        ShipmentDescription,
        FromMaterial
    )
    SELECT
        ta._ScenarioID,
        'Piles_to_Ships',
        ta.FromLocation,
        ta.ToLocation,
        ta.ShipmentDescription,
        get_part_from_to_code(ta.ShipmentDescription, 1, 2)
    FROM
        T_EO_ItI_TransferActivity ta
    WHERE
        ta._ScenarioID = ConfigId
        AND ta.ObjectName = 'Piles_to_Ships';
END;
$$;