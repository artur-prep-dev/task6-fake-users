CREATE OR REPLACE FUNCTION random_uniform(key text)
RETURNS double precision
LANGUAGE plpgsql IMMUTABLE
AS $$
DECLARE
    hash text;
    hex_digits text := '0123456789abcdef';
    number bigint := 0;
BEGIN
    hash := md5(key);
    FOR i IN 1..12 LOOP
        number := number * 16 + position(substr(hash, i, 1) IN hex_digits) - 1;
    END LOOP;
    RETURN number::double precision / 281474976710656;
END;
$$;

CREATE OR REPLACE FUNCTION random_int(key text, min_value integer, max_value integer)
RETURNS integer
LANGUAGE plpgsql IMMUTABLE
AS $$
DECLARE
    u double precision;
BEGIN
    u := random_uniform(key);
    RETURN min_value + floor((max_value - min_value + 1) * u);
END;
$$;

CREATE OR REPLACE FUNCTION random_normal(key text, mean double precision, std double precision)
RETURNS double precision
LANGUAGE plpgsql IMMUTABLE
AS $$
DECLARE
    u1 double precision;
    u2 double precision;
BEGIN
    u1 := random_uniform(key || ':a');
    u2 := random_uniform(key || ':b');
    RETURN mean + std * sqrt(-2 * ln(1 - u1)) * cos(2 * pi() * u2);
END;
$$;
