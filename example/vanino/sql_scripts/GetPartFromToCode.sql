CREATE OR REPLACE FUNCTION public.get_part_from_to_code(
    code varchar(2048),
    from_pos integer,
    to_pos integer
)
RETURNS varchar(1024)
LANGUAGE plpgsql
AS $$
DECLARE
    i integer := 1;
    result varchar(1024) := '';
    pos integer;
    part_length integer;
BEGIN
    WHILE i <= to_pos LOOP
        IF code = '' THEN
            RETURN result;
        END IF;

        pos := position('|' IN code);

        IF i >= from_pos THEN
            IF pos != 0 THEN
                part_length := pos - 1;
            ELSE
                part_length := length(code);
            END IF;

            result := result || substring(code FROM 1 FOR part_length);
        END IF;

        IF pos = 0 THEN
            RETURN result;
        END IF;

        code := substring(code FROM pos + 1);
        i := i + 1;
    END LOOP;

    RETURN substring(result FROM 1 FOR length(result) - 1);
END;
$$;