CREATE OR REPLACE PROCEDURE SChaMa_EO_P_PurchaseActivityMTP_Incoming_sp(
    ConfigId INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Delete existing records for this config
    DELETE FROM T_EO_P_PurchaseActivityMTP
    WHERE _ScenarioID = ConfigId;

    -- Create temporary table for Piles in Purchase ActivityMTP "Incoming"
    CREATE TEMPORARY TABLE Temp_PurMTP AS
    SELECT
        pl._ScenarioID,
        'Incoming' AS ObjectName,
        tp.TimePeriod,
        ld.Location,
        CONCAT(pl.PileCode, '|', pl.PileName) AS ItemDescription,
        CASE
            WHEN CAST(tp.TimePeriod AS INT) <= pl.ConfirmedDays THEN
                pl.ConfirmedVolume / pl.ConfirmedDays
            WHEN CAST(tp.TimePeriod AS INT) > pl.ConfirmedDays
                 AND CAST(tp.TimePeriod AS INT) <= pl.DVZHDDays + pl.ConfirmedDays THEN
                pl.DVZHDVolume / pl.DVZHDDays
            WHEN CAST(tp.TimePeriod AS INT) > pl.DVZHDDays + pl.ConfirmedDays
                 AND CAST(tp.TimePeriod AS INT) <= pl.DVZHDDays + pl.ConfirmedDays + pl.FarawayDays THEN
                pl.FarawayVolume / pl.FarawayDays
            WHEN CAST(tp.TimePeriod AS INT) > pl.DVZHDDays + pl.ConfirmedDays + pl.FarawayDays
                 AND CAST(tp.TimePeriod AS INT) <= pl.DVZHDDays + pl.ConfirmedDays + pl.FarawayDays + pl.PlannedDays THEN
                pl.PlannedVolume / pl.PlannedDays
            ELSE
                pl.LongRunVolume / pl.LongRunDays
        END / 1000 AS MinUnitsAdd,
        MinUnitsAdd AS MaxUnitsAdd
    FROM T_Piles pl
    CROSS JOIN (
        SELECT Location
        FROM T_EO_E_LocationDefinitions
        WHERE Tag1 = 'Piles'
              AND _ScenarioID = ConfigId
        LIMIT 1
    ) ld
    CROSS JOIN (
        SELECT TimePeriod
        FROM T_EO_E_TimePeriodDefinitions
        WHERE _ScenarioID = ConfigId
    ) tp
    WHERE pl._ScenarioID = ConfigId;

    -- Insert telescoped periods into final table
    INSERT INTO T_EO_P_PurchaseActivityMTP(
        _ScenarioID,
        ObjectName,
        TimePeriod,
        Location,
        ItemDescription,
        MinUnitsAdd,
        MaxUnitsAdd
    )
    SELECT
        pur._ScenarioID,
        pur.ObjectName,
        tpd.Tag2,
        pur.Location,
        pur.ItemDescription,
        SUM(pur.MinUnitsAdd),
        SUM(pur.MaxUnitsAdd)
    FROM Temp_PurMTP pur
    JOIN T_EO_E_TimePeriodDefinitions tpd
        ON tpd.TimePeriod = pur.TimePeriod
           AND tpd._ScenarioID = ConfigId
    GROUP BY
        pur._ScenarioID,
        pur.ObjectName,
        tpd.Tag2,
        pur.Location,
        pur.ItemDescription;

    -- Insert day items into Purchase ActivityMTP "Incoming"
    INSERT INTO T_EO_P_PurchaseActivityMTP(
        _ScenarioID,
        ObjectName,
        TimePeriod,
        Location,
        ItemDescription,
        MinUnitsAdd,
        MaxUnitsAdd
    )
    SELECT
        pa._ScenarioID,
        'Incoming',
        tp.Tag2,
        pa.Location,
        pa.ItemDescription,
        0,
        2 -- Причалы
    FROM T_EO_P_PurchaseActivity pa
    JOIN T_EO_E_TimePeriodDefinitions tpd
        ON tpd.TimePeriod = get_part_from_to_code(pa.ItemDescription,2,2)
           AND pa._ScenarioID = tpd._ScenarioID
    CROSS JOIN (
        SELECT DISTINCT Tag2
        FROM T_EO_E_TimePeriodDefinitions
        WHERE _ScenarioID = ConfigId
    ) tp
    WHERE pa._ScenarioID = ConfigId
          AND pa.Location = 'Days'
          AND tpd.Tag2 = tp.Tag2;

    -- Clean up temporary table
    DROP TABLE IF EXISTS Temp_PurMTP;
END;
$$;