CREATE OR REPLACE PROCEDURE public.eosms_run_all_sp(config_id INT)
RETURNS VOID AS $$
DECLARE
    debug_level INT := 0;
    startdate TIMESTAMP;
    endtime TIMESTAMP;
BEGIN
    -- Создание временной таблицы для отслеживания времени выполнения
    IF debug_level > 2 THEN
        CREATE TEMP TABLE IF NOT EXISTS trace (
            row_num SERIAL PRIMARY KEY,
            duration INTERVAL,
            procedure_name VARCHAR(255)
        );
    END IF;

    -- Начало транзакции
    BEGIN
        -- Пример выполнения хранимой процедуры
        startdate := clock_timestamp();
        PERFORM public.eo_temp_active_vessel_sp(config_id);
        IF NOT FOUND THEN
            RAISE EXCEPTION 'Ошибка при выполнении eo_temp_active_vessel_sp';
        END IF;
        endtime := clock_timestamp();
        IF debug_level > 2 THEN
            INSERT INTO trace (duration, procedure_name)
            VALUES (endtime - startdate, 'eo_temp_active_vessel_sp');
        END IF;

        startdate := clock_timestamp();
        PERFORM public.eo_e_time_period_definitions_sp(config_id);
        IF NOT FOUND THEN
            RAISE EXCEPTION 'Ошибка при выполнении eo_e_time_period_definitions_sp';
        END IF;
        endtime := clock_timestamp();
        IF debug_level > 2 THEN
            INSERT INTO trace (duration, procedure_name)
            VALUES (endtime - startdate, 'eo_e_time_period_definitions_sp');
        END IF;

        startdate := clock_timestamp();
        PERFORM public.eo_a_attribute_definitions_sp(config_id);
        IF NOT FOUND THEN
            RAISE EXCEPTION 'Ошибка при выполнении eo_a_attribute_definitions_sp';
        END IF;
        endtime := clock_timestamp();
        IF debug_level > 2 THEN
            INSERT INTO trace (duration, procedure_name)
            VALUES (endtime - startdate, 'eo_a_attribute_definitions_sp');
        END IF;

        -- Продолжайте с остальными вызовами хранимых процедур аналогично...

        -- Завершение транзакции
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
          RAISE NOTICE 'Произошла ошибка: %', SQLERRM;

    END;
END;
$$ LANGUAGE plpgsql;