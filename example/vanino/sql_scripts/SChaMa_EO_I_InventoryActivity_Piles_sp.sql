-- ==================================================================
-- Author:      NY
-- Create date: 30.11.2020
-- Project:     SChaMa - Vanino
-- Description: Filling EO_I_InventoryActivity Obj_name=Piles
-- ==================================================================
CREATE OR REPLACE PROCEDURE schama_eo_i_inventoryactivity_piles_sp(
    ConfigId INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Удаляем старые данные для указанного ConfigId
    DELETE FROM T_EO_I_InventoryActivity
    WHERE _ScenarioID = ConfigId
    AND ObjectName = 'Piles';

    -- Piles in Inventory Activity "Piles"
    INSERT INTO T_EO_I_InventoryActivity
        (_ScenarioID,
         ObjectName,
         Location,
         Material,
         MinBeginUnitsFirstPeriod,
         MaxBeginUnitsFirstPeriod,
         MinCarryforwardUnits,
         Tag1)
    SELECT
        pa._ScenarioID,
        'Piles',
        pa.Location,
        pa.ItemDescription,
        (pl.StockYard + pl.OnBoard) / 1000,
        (pl.StockYard + pl.OnBoard) / 1000,
        pl.MinStock / 1000,
        pl.Id
    FROM
        T_EO_P_PurchaseActivity pa
        JOIN T_Piles pl ON pl._ScenarioID = pa._ScenarioID
                         AND pl.PileCode = pa.Tag1
    WHERE
        pa._ScenarioID = ConfigId
        AND pa.ObjectName = 'Incoming';
END;
$$;