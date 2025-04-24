CREATE OR REPLACE PROCEDURE schama_eo_e_locationdefinitionsmtp_sp(ConfigId INT)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Delete existing records for this ConfigId
    DELETE FROM t_eo_e_locationdefinitionsmtp
    WHERE _ScenarioID = ConfigId;

    -- Create temporary tables
    CREATE TEMPORARY TABLE temp_loc_mtp (
        location TEXT,
        timeperiod TEXT,
        decswitch TEXT
    );

    -- Insert into temp table - Sales locations
    INSERT INTO temp_loc_mtp
    SELECT  loc.location,
            tpd.timeperiod,
            CASE WHEN tpd.tag1 NOT IN ('H', 'W')
                 THEN CASE
                        WHEN tpd.periodindex BETWEEN
                                        CAST (get_part_from_to_code(loc.location, 6, 6) AS INT)
                                      AND
                                        CAST (get_part_from_to_code(loc.location, 6, 6) AS INT)
                                              + ves.daystoload - 1
                        THEN 'Open'
                        ELSE 'Closed'
                      END
                 WHEN (tpd_st.tag2 = tpd.tag2 OR tpd_fin.tag2 = tpd.tag2)
                 THEN 'Open'
                 ELSE 'Closed'
            END AS decswitch
    FROM    t_eo_e_locationdefinitions AS loc
            JOIN t_eotemp_activevessel AS ves
              ON ves.eo_vessel = loc.tag2 AND loc._ScenarioID = ves._ScenarioID
            JOIN t_eo_e_timeperioddefinitions AS tpd_st
              ON tpd_st.timeperiod = get_part_from_to_code(loc.location, 6, 6)
              AND loc._ScenarioID = tpd_st._ScenarioID
            JOIN t_eo_e_timeperioddefinitions AS tpd_fin
              ON tpd_fin.periodindex = CAST (get_part_from_to_code(loc.location, 6, 6) AS INT) + ves.daystoload - 1
              AND loc._ScenarioID = tpd_fin._ScenarioID
            CROSS JOIN t_eo_e_timeperioddefinitions AS tpd
    WHERE   loc._ScenarioID = ConfigId
            AND loc._ScenarioID = tpd._ScenarioID
            AND loc.tag1 = 'Sales';

    -- Insert into temp table - Ships locations
    INSERT INTO temp_loc_mtp
    SELECT  loc.location,
            tpd.timeperiod,
            CASE WHEN CAST (get_part_from_to_code(tpd.tag2, 1, 1) AS INT) < CAST (get_part_from_to_code(tpd_st.tag2, 1, 1) AS INT)
                 THEN 'Closed'
                 ELSE 'Decide'
            END AS decswitch
    FROM    t_eo_e_locationdefinitions AS loc
            JOIN t_eotemp_activevessel AS ves
              ON ves.eo_vessel = loc.tag2 AND loc._ScenarioID = ves._ScenarioID
            JOIN t_eo_e_timeperioddefinitions AS tpd_st
              ON tpd_st.periodindex = ves.dayofstart AND loc._ScenarioID = tpd_st._ScenarioID
            CROSS JOIN t_eo_e_timeperioddefinitions AS tpd
    WHERE   loc._ScenarioID = ConfigId
            AND loc._ScenarioID = tpd._ScenarioID
            AND loc.tag1 = 'Ships';

    -- Create second temp table
    CREATE TEMPORARY TABLE temp_loc_mtp_tele (
        location TEXT,
        timeperiod TEXT,
        decswitch TEXT
    );

    -- Insert into second temp table
    INSERT INTO temp_loc_mtp_tele
    SELECT t.location, t.tag2 AS timeperiod, t.decswitch
    FROM (SELECT loc.*, tpd.tag2,
                 ROW_NUMBER() OVER (PARTITION BY loc.location, tpd.tag2 ORDER BY loc.location, loc.timeperiod) AS rn
          FROM temp_loc_mtp loc
          JOIN t_eo_e_timeperioddefinitions tpd
            ON tpd.timeperiod = loc.timeperiod AND tpd._ScenarioID = ConfigId) AS t
    WHERE t.rn = 1;

    -- Insert into final table
    INSERT INTO t_eo_e_locationdefinitionsmtp
        (_ScenarioID, location, timeperiod, decisionswitch)
    SELECT
        ConfigId, location, timeperiod, decswitch
    FROM
        temp_loc_mtp_tele;

    -- Clean up
    DROP TABLE IF EXISTS temp_loc_mtp;
    DROP TABLE IF EXISTS temp_loc_mtp_tele;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error in schama_eo_e_locationdefinitionsmtp_sp: (%)', SQLERRM;
        -- Clean up in case of error
        DROP TABLE IF EXISTS temp_loc_mtp;
        DROP TABLE IF EXISTS temp_loc_mtp_tele;
END;
$$;