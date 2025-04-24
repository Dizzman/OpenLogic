-- ==================================================================
-- Author:      NY
-- Create date: 30.11.2020
-- Project:     SChaMa - Vanino
-- Description: Filling EO_ItS_MixDistribution Obj_name=Ships_to_Sales
-- ==================================================================
CREATE OR REPLACE PROCEDURE schama_eo_its_mixdistribution_ships_to_sales_sp(configid INT)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Delete existing data for specified ConfigId
    DELETE FROM t_eo_its_mixdistribution
    WHERE _ScenarioID = configid
    AND objectname = 'Ships_to_Sales';

    -- Fill Link ItS "Ships_to_Sales"
    INSERT INTO t_eo_its_mixdistribution
        (_ScenarioID,
         objectname,
         fromlocation,
         tolocation,
         itemdescription,
         material)
    SELECT
        sa._ScenarioID,
        'Ships_to_Sales',
        get_part_from_to_code(sa.location, 1, 5),
        sa.location,
        sa.itemdescription,
        sa.itemdescription
    FROM
        t_eo_s_salesactivity    sa
    WHERE
        sa._ScenarioID = configid
        AND sa.objectname = 'Sales';
END;
$$;