CREATE OR REPLACE FUNCTION random_word(p_locale text, p_category text, key text)
RETURNS text
LANGUAGE plpgsql STABLE
AS $$
DECLARE
    word_count integer;
    word_number integer;
    word text;
BEGIN
    SELECT total INTO word_count
    FROM word_counts
    WHERE locale = p_locale AND category = p_category;

    word_number := random_int(key, 0, word_count - 1);

    SELECT value INTO word
    FROM words
    WHERE locale = p_locale AND category = p_category AND idx = word_number;

    RETURN word;
END;
$$;

CREATE OR REPLACE FUNCTION random_latitude(key text)
RETURNS double precision
LANGUAGE plpgsql IMMUTABLE
AS $$
DECLARE
    u double precision;
BEGIN
    u := random_uniform(key);
    RETURN degrees(asin(2 * u - 1));
END;
$$;

CREATE OR REPLACE FUNCTION random_longitude(key text)
RETURNS double precision
LANGUAGE plpgsql IMMUTABLE
AS $$
DECLARE
    u double precision;
BEGIN
    u := random_uniform(key);
    RETURN 360 * u - 180;
END;
$$;
