-- ==================================================================
-- Author:      NY
-- Create date: 30.11.2020
-- Project:     SChaMa - Vanino
-- Description: Filling EO_ItI_TransferActivity Obj_name=Piles_to_Ships
-- ==================================================================
CREATE OR REPLACE PROCEDURE SChaMa_EO_ItI_TransferActivity_Piles_to_Ships_sp(configid INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Delete existing data for specified ConfigId
    DELETE FROM t_eo_iti_transferactivity
    WHERE _ScenarioID = configid
    AND objectname = 'Piles_to_Ships';

    -- Fill TransferActivity for Link "Piles_to_Ships"
    INSERT INTO t_eo_iti_transferactivity
        (_ScenarioID,
         objectname,
         fromlocation,
         tolocation,
         shipmentdescription,
         costpershipment,
         mintotalshipments,
         maxtotalshipments,
         variabletype,
         tag1,
         tag2)
    SELECT
        iap._ScenarioID,
        'Piles_to_Ships',
        iap.location,
        ias.location,
        CONCAT(RTRIM(iap.material), '|', RTRIM(ias.material)),
        vl.revenue * -1,
        vl.minvolume / 1000,
        vl.maxvolume / 1000,
        'Continuous',
        vl.vesselid,
        vl.pileid
    FROM
        t_eo_i_inventoryactivity iap
        CROSS JOIN t_eo_i_inventoryactivity ias
        JOIN T_volumes vl ON vl.vesselid = CAST(ias.tag1 AS INT)
                           AND vl.pileid = CAST(iap.tag1 AS INT)
    WHERE
        iap._ScenarioID = configId
        AND iap.objectname = 'Piles'
        AND ias._ScenarioID = iap._ScenarioID
        AND ias.objectname = 'Ships'
        AND COALESCE(get_part_from_to_code(ias.material, 5, 5), '') = ''
        AND get_part_from_to_code(ias.material, 1, 1) <> 'Day';  -- #1: Original filter condition
END;
$$;