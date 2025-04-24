-- ==================================================================
-- Author:      NY
-- Create date: 30.11.2020
-- Project:     SChaMa - Vanino
-- Description: Filling EO_I_InventoryActivity Obj_name=Ships
-- ==================================================================
CREATE OR REPLACE PROCEDURE schama_eo_i_inventoryactivity_ships_sp(configId INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Delete existing data for specified ConfigId
    DELETE FROM t_eo_i_inventoryactivity
    WHERE _ScenarioID = configId
    AND objectname = 'Ships';

    -- Ships in Inventory Activity "Ships"
    INSERT INTO t_eo_i_inventoryactivity
        (_ScenarioID,
         objectname,
         location,
         material,
         maxbeginunitsfirstperiod,
         maxendunitslastperiod,
         maxcarryforwardunits,
         tag1)
    SELECT DISTINCT
        md._ScenarioID,
        'Ships',
        md.fromlocation,
        md.material,
        0,
        0,
        0,
        sa.tag1
    FROM
        t_eo_its_mixdistribution md
        JOIN t_eo_s_salesactivity sa ON sa._ScenarioID = md._ScenarioID
                                      AND sa.itemdescription = md.itemdescription
                                      AND sa.location = md.tolocation  -- #1: Original join condition
    WHERE
        md._ScenarioID = configId
        AND md.objectname = 'Ships_to_Sales';
END;
$$;