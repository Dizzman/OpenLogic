-- ==================================================================
-- Author:      NY
-- Create date: 10.01.2018
-- Description: Filling EO_ItI_FromShipmentDescription  Obj_name=Piles_to_Ships
--              version for Day Items - no change
-- ================================================================
CREATE OR REPLACE PROCEDURE SChaMa_EO_ItI_FromShipmentDescription_Piles_to_Ships_sp(ConfigId INT)
LANGUAGE plpgsql
AS $$
BEGIN

    DELETE FROM T_EO_ItI_FromShipmentDescription
    WHERE _ScenarioID = ConfigId
          AND ObjectName = 'Piles_to_Ships';


-- Fill EO_ItI_FromShipmentDescription for Link "Piles_to_Ships"

INSERT INTO T_EO_ItI_FromShipmentDescription
    (_ScenarioID,
     ObjectName,
     FromLocation,
     ToLocation,
     ShipmentDescription,
     FromMaterial)
    SELECT ta._ScenarioID,
           'Piles_to_Ships',
           ta.FromLocation,
           ta.ToLocation,
           ta.ShipmentDescription,
           get_part_from_to_code(ta.ShipmentDescription, 1, 2)
    FROM T_EO_ItI_TransferActivity ta
    WHERE ta._ScenarioID = ConfigId
          AND ta.ObjectName = 'Piles_to_Ships';

END;
$$;