-- ================================================================
-- Author:      NY
-- Create date: 30.11.2020
-- Project:     SChaMa - Vanino
-- Description: Filling EO_S_SalesActivityMTP Obj_name=Sales
-- ================================================================
CREATE OR REPLACE PROCEDURE SChaMa_EO_S_SalesActivityMTP_Sales_sp(
    ConfigId INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Delete existing records for this config
    DELETE FROM T_EO_S_SalesActivityMTP
    WHERE _ScenarioID = ConfigId
          AND ObjectName = 'Sales';

    -- Vessels with tonnage in Sales ActivityMTP "Sales" in Week and 2Week periods
    INSERT INTO T_EO_S_SalesActivityMTP(
        _ScenarioID,
        ObjectName,
        TimePeriod,
        Location,
        ItemDescription,
        MaxUnitsFactor
    )
    SELECT
        sa._ScenarioID,
        'Sales',
        tpd.Tag2,
        sa.Location,
        sa.ItemDescription,
        CASE
            WHEN tpd.Tag1 = 'W' THEN 7
            ELSE 14
        END
    FROM
        T_EO_S_SalesActivity sa
        JOIN T_EOtemp_ActiveVessel av ON av._ScenarioID = sa._ScenarioID
                                   AND av.VesselId = CAST(sa.Tag1 AS INT)
        JOIN T_EO_E_LocationDefinitions ld ON ld._ScenarioID = sa._ScenarioID
                                       AND sa.Location = ld.Location
        JOIN T_EO_E_TimePeriodDefinitions AS TPD_st ON TPD_st.TimePeriod = get_part_from_to_code(sa.Location, 6, 6)
                                                 AND sa._ScenarioID = TPD_st._ScenarioID
        JOIN T_EO_E_TimePeriodDefinitions AS TPD_fin ON TPD_fin.PeriodIndex = CAST(get_part_from_to_code(sa.Location, 6, 6) AS INTEGER) + av.DaysToLoad - 1
                                                   AND sa._ScenarioID = TPD_fin._ScenarioID
        CROSS JOIN (
            SELECT DISTINCT Tag1, Tag2
            FROM T_EO_E_TimePeriodDefinitions
            WHERE _ScenarioID  = ConfigId
                  AND Tag1 IN ('H', 'W')
        ) AS tpd
    WHERE
        av._ScenarioID  = ConfigId
        AND ld.Tag1 = 'Sales'
        AND (
            TPD_st.Tag2 = tpd.Tag2
            OR TPD_fin.Tag2 = tpd.Tag2
        )
        AND COALESCE(sa.Attribute1, '') <> '';
END;
$$;