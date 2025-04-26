CREATE OR REPLACE FUNCTION public.get_part_from_to_code(
    p_code text,
    p_from int,
    p_to int
)
RETURNS text AS $$
DECLARE
    i int := 1;
    result text := '';
    parts text[];
BEGIN
    -- Если входная строка пустая или NULL, возвращаем пустую строку
    IF p_code IS NULL OR p_code = '' THEN
        RETURN '';
    END IF;

    -- Разбиваем строку на части по разделителю '|'
    parts := string_to_array(p_code, '|');

    -- Проверяем допустимость диапазона
    IF p_from < 1 OR p_from > array_length(parts, 1) OR
       p_to < p_from OR p_to > array_length(parts, 1) THEN
        RETURN '';
    END IF;

    -- Собираем нужные части
    FOR i IN p_from..p_to LOOP
        IF result = '' THEN
            result := parts[i];
        ELSE
            result := result || '|' || parts[i];
        END IF;
    END LOOP;

    RETURN result;
END;
$$ LANGUAGE plpgsql IMMUTABLE STRICT;