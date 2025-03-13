CREATE OR REPLACE PROCEDURE EO_E_TimePeriodDefinitions_sp(ConfigId INT)
LANGUAGE plpgsql
AS $$
DECLARE
    MaxDays INT;
    DayNumber INT := 1;
BEGIN
    -- Получаем количество дней из таблицы Configuration
    SELECT NumberOfDays + 1 INTO MaxDays
    FROM Configuration
    WHERE Id = ConfigId;

    -- Создаем временную таблицу для хранения дней
    CREATE TEMP TABLE Days (DayNumber INT);

    -- Заполняем временную таблицу днями
    WHILE DayNumber <= MaxDays LOOP
        INSERT INTO Days (DayNumber)
        VALUES (DayNumber);
        DayNumber := DayNumber + 1;
    END LOOP;

    -- Удаляем старые данные для указанного ConfigId
    DELETE FROM EO_E_TimePeriodDefinitions
    WHERE _scenarioid = ConfigId;

    -- Вставляем новые данные
    INSERT INTO EO_E_TimePeriodDefinitions
        (_scenarioid, TimePeriod, Tag1, PeriodIndex)
    SELECT
        c.id,
        CASE
            WHEN LENGTH(CAST(d.DayNumber AS VARCHAR)) = 1
            THEN '0' || CAST(d.DayNumber AS VARCHAR)
            ELSE CAST(d.DayNumber AS VARCHAR)
        END AS TimePeriod,
        CASE
            WHEN d.DayNumber <= c.NumberOfDiscreteDays
            THEN 'D'
            ELSE ''
        END AS Tag1,
        d.DayNumber AS PeriodIndex
    FROM
        Configuration c
    CROSS JOIN Days d
    WHERE
        c.Id = ConfigId;

    -- Удаляем временную таблицу
    DROP TABLE Days;
END;
$$;