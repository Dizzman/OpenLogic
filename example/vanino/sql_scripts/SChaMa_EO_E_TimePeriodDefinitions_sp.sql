-- =============================================
-- Author:        NY
-- Create date: 30.11.2020
-- Project:        SChaMa - Vanino
-- Description:    Filling EO_E_TimePeriodDefinitions with 2-digit day numbers
-- =============================================
CREATE OR REPLACE PROCEDURE SChaMa_EO_E_TimePeriodDefinitions_sp(
    p_ConfigId INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_MaxDays INTEGER;
    v_DiscDays INTEGER;
    v_DayNumber INTEGER := 1;
    v_PeriodType TEXT;
    v_DayInWeek INTEGER;
    v_NewWeek INTEGER;
    v_WeekNumber INTEGER := 1;
    v_PeriodNumber INTEGER;
    v_DayIn2Week INTEGER;
    v_New2Week INTEGER;
    v_2WeekNumber INTEGER := 1;
BEGIN
    -- Create temporary table for days
    CREATE TEMP TABLE Days (
        DayNumber INTEGER,
        Tag1 TEXT,
        Tag2 TEXT
    ) ON COMMIT DROP;

    -- Get configuration values
    SELECT NumberOfDays + 1, NumberOfDiscreteDays
    INTO v_MaxDays, v_DiscDays
    FROM T_Configuration WHERE ID = p_ConfigId;

    -- Process daily periods
    WHILE v_DayNumber <= v_MaxDays LOOP
        v_PeriodType := CASE
            WHEN v_DayNumber <= v_DiscDays THEN 'D'
            ELSE ''
        END;

        INSERT INTO Days (DayNumber, Tag1, Tag2)
        VALUES (v_DayNumber, v_PeriodType, CAST(v_DayNumber AS TEXT));

        v_DayNumber := v_DayNumber + 1;
    END LOOP;

    -- Get next period configuration
    SELECT NumberOfDays + 1 + NumberOfWeekPeriods*7
    INTO v_MaxDays
    FROM T_Configuration WHERE ID = p_ConfigId;

    v_PeriodType := 'W';
    v_DayInWeek := 1;
    v_PeriodNumber := v_DayNumber;

    -- Process weekly periods
    WHILE v_DayNumber <= v_MaxDays LOOP
        INSERT INTO Days (DayNumber, Tag1, Tag2)
        VALUES (
            v_DayNumber,
            v_PeriodType,
            CAST(v_PeriodNumber AS TEXT) || '|' || v_PeriodType || CAST(v_WeekNumber AS TEXT)
        );

        v_DayNumber := v_DayNumber + 1;
        v_DayInWeek := CASE WHEN v_DayInWeek = 7 THEN 1 ELSE v_DayInWeek + 1 END;
        v_NewWeek := CASE WHEN v_DayInWeek = 1 THEN 1 ELSE 0 END;
        v_WeekNumber := v_WeekNumber + v_NewWeek;
        v_PeriodNumber := v_PeriodNumber + v_NewWeek;
    END LOOP;

    -- Get next period configuration
    SELECT NumberOfDays + 1 + NumberOfWeekPeriods*7 + NumberOf2WeekPeriods*14
    INTO v_MaxDays
    FROM T_Configuration WHERE ID = p_ConfigId;

    v_PeriodType := 'H';
    v_DayIn2Week := 1;

    -- Process bi-weekly periods
    WHILE v_DayNumber <= v_MaxDays LOOP
        INSERT INTO Days (DayNumber, Tag1, Tag2)
        VALUES (
            v_DayNumber,
            v_PeriodType,
            CAST(v_PeriodNumber AS TEXT) || '|' || v_PeriodType || CAST(v_2WeekNumber AS TEXT)
        );

        v_DayNumber := v_DayNumber + 1;
        v_DayIn2Week := CASE WHEN v_DayIn2Week = 14 THEN 1 ELSE v_DayIn2Week + 1 END;
        v_New2Week := CASE WHEN v_DayIn2Week = 1 THEN 1 ELSE 0 END;
        v_2WeekNumber := v_2WeekNumber + v_New2Week;
        v_PeriodNumber := v_PeriodNumber + v_New2Week;
    END LOOP;

    -- Update target table
    DELETE FROM T_EO_E_TimePeriodDefinitions
    WHERE _ScenarioID = p_ConfigId;

    INSERT INTO T_EO_E_TimePeriodDefinitions
        (_ScenarioID, TimePeriod, Tag1, Tag2, PeriodIndex)
    SELECT
        c.ID,
        CASE WHEN LENGTH(CAST(d.DayNumber AS TEXT)) = 1
             THEN '0' ELSE '' END || CAST(d.DayNumber AS TEXT),
        d.Tag1,
        CASE WHEN LENGTH(CAST(d.Tag2 AS TEXT)) = 1
             THEN '0' ELSE '' END || CAST(d.Tag2 AS TEXT),
        d.DayNumber
    FROM
        T_Configuration c
    CROSS JOIN Days d
    WHERE
        c.ID = p_ConfigId;
END;
$$;