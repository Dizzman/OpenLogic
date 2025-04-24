-- ==================================================================
-- Author:      SS
-- Create date: 30.10.2017
-- Description: Filling EO_P_PurchaseActivityMTP Obj_name=Incoming
-- Change #1 Author:     SS
-- Create date: 10.01.2018
-- Description: Filling EO_P_PurchaseActivityMTP Obj_name=Incoming with Day items
-- ================================================================
CREATE OR REPLACE PROCEDURE schama_eo_p_purchaseactivitymtp_incoming_sp( configid INT)
LANGUAGE plpgsql
AS $$
BEGIN

    DELETE FROM t_eo_p_purchaseactivitymtp
    WHERE _scenarioID = configid;

    -- Piles in Purchase ActivityMTP "Incoming"
    INSERT INTO t_eo_p_purchaseactivitymtp
        (_scenarioID, objectname, timeperiod, location, itemdescription, minunitsadd, maxunitsadd)
    SELECT
        pl._scenarioID,
        'Incoming',
        tp.timeperiod,
        ld.location,
        CONCAT(pl.pilecode, '|', pl.pilename),
        CASE
            WHEN CAST(tp.timeperiod as INT) <= pl.confirmeddays
                THEN pl.confirmedvolume / pl.confirmeddays
            WHEN CAST(tp.timeperiod as INT) > pl.confirmeddays AND CAST(tp.timeperiod as INT) <= pl.dvzhddays + pl.confirmeddays
                THEN pl.dvzhdvolume / pl.dvzhddays
            WHEN CAST(tp.timeperiod as INT) > pl.dvzhddays + pl.confirmeddays AND CAST(tp.timeperiod as INT) <= pl.dvzhddays + pl.confirmeddays + pl.farawaydays
                THEN pl.farawayvolume / pl.farawaydays
            WHEN CAST(tp.timeperiod as INT) > pl.dvzhddays + pl.confirmeddays + pl.farawaydays AND CAST(tp.timeperiod as INT) <= pl.dvzhddays + pl.confirmeddays + pl.farawaydays + pl.planneddays
                THEN pl.plannedvolume / pl.planneddays
            ELSE pl.longrunvolume / pl.longrundays
        END / 1000,
        CASE
            WHEN CAST(tp.timeperiod as INT) <= pl.confirmeddays
                THEN pl.confirmedvolume / pl.confirmeddays
            WHEN CAST(tp.timeperiod as INT) > pl.confirmeddays AND CAST(tp.timeperiod as INT) <= pl.dvzhddays + pl.confirmeddays
                THEN pl.dvzhdvolume / pl.dvzhddays
            WHEN CAST(tp.timeperiod as INT) > pl.dvzhddays + pl.confirmeddays AND CAST(tp.timeperiod as INT) <= pl.dvzhddays + pl.confirmeddays + pl.farawaydays
                THEN pl.farawayvolume / pl.farawaydays
            WHEN CAST(tp.timeperiod as INT) > pl.dvzhddays + pl.confirmeddays + pl.farawaydays AND CAST(tp.timeperiod as INT) <= pl.dvzhddays + pl.confirmeddays + pl.farawaydays + pl.planneddays
                THEN pl.plannedvolume / pl.planneddays
            ELSE pl.longrunvolume / pl.longrundays
        END / 1000
    FROM
        t_piles pl
    CROSS JOIN (
        SELECT location
        FROM t_eo_e_locationdefinitions
        WHERE tag1 = 'Piles'
        AND _scenarioID = configid
        LIMIT 1
    ) ld
    CROSS JOIN (
        SELECT timeperiod
        FROM t_eo_e_timeperioddefinitions
        WHERE _scenarioID = configid
    ) tp
    WHERE
        pl._scenarioID = configid;

    -- Day items in Purchase ActivityMTP "Incoming"
    INSERT INTO t_eo_p_purchaseactivitymtp
        (_scenarioID, objectname, timeperiod, location, itemdescription, minunitsadd, maxunitsadd)
    SELECT
        pa._scenarioID,
        'Incoming',
        tp.timeperiod,
        pa.location,
        pa.itemdescription,
        0,
        CASE
            WHEN get_part_from_to_code(pa.itemdescription, 2, 2) = tp.timeperiod THEN 2
            ELSE 0
        END
    FROM
        t_eo_p_purchaseactivity pa
    CROSS JOIN (
        SELECT timeperiod
        FROM t_eo_e_timeperioddefinitions
        WHERE _scenarioID = configid
    ) tp
    WHERE
        pa._scenarioID = configid AND pa.location = 'Days';

END;
$$;