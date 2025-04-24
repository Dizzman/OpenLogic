-- =============================================
-- Author:      NY
-- Create date: 30.11.2020
-- Project:     SChaMa - Vanino
-- Description: Filling EO_P_PurchaseActivity with incoming purchase data
-- =============================================
CREATE OR REPLACE PROCEDURE schama_eo_p_purchaseactivity_incoming_sp(
    IN ConfigId INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Delete existing records for this ConfigId
    DELETE FROM t_eo_p_purchaseactivity
    WHERE _ScenarioID = ConfigId;

    -- Piles in Purchase Activity "Incoming"
    INSERT INTO t_eo_p_purchaseactivity
        (_ScenarioID, objectname, location, itemdescription, maxunitsperperiod, tag1)
    SELECT
        pl._ScenarioID,
        'Incoming',
        ld.location,
        CONCAT(RTRIM(pl.pilecode), '|', RTRIM(pl.pilename)),
        0,
        pl.pilecode
    FROM
        t_piles pl
        CROSS JOIN (
            SELECT location
            FROM t_eo_e_locationdefinitions
            WHERE tag1 = 'Piles'
              AND configid = ConfigId
            LIMIT 1
        ) ld
    WHERE
        pl._ScenarioID = ConfigId;

    -- Day items in Purchase Activity "Incoming"
    INSERT INTO t_eo_p_purchaseactivity
        (_ScenarioID, objectname, location, itemdescription, maxunitsperperiod, tag1)
    SELECT
        tp._ScenarioID,
        'Incoming',
        'Days',
        CONCAT('Day', '|', RTRIM(tp.timeperiod)),
        0,
        NULL
    FROM
        t_eo_e_timeperioddefinitions tp
    WHERE
        tp._ScenarioID = ConfigId;
END;
$$;