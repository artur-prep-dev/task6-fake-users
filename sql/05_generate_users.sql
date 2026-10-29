CREATE OR REPLACE FUNCTION generate_users(p_locale text, p_seed bigint, p_batch integer, p_size integer DEFAULT 10)
RETURNS TABLE (
    num integer,
    full_name text,
    address text,
    latitude numeric,
    longitude numeric,
    height_cm numeric,
    weight_kg numeric,
    eye_color text,
    phone text,
    email text
)
LANGUAGE plpgsql STABLE
AS $$
DECLARE
    person_key text;
    gender text;
    first_name text;
    last_name text;
    average_height double precision;
    height_spread double precision;
    average_weight double precision;
    weight_spread double precision;
BEGIN
    FOR i IN 1..p_size LOOP
        person_key := p_locale || '|' || p_seed || '|' || p_batch || '|' || i;

        IF random_uniform(person_key || '|gender') < 0.5 THEN
            gender := 'male';
            average_height := 178;
            height_spread := 7;
            average_weight := 82;
            weight_spread := 12;
        ELSE
            gender := 'female';
            average_height := 165;
            height_spread := 6;
            average_weight := 66;
            weight_spread := 10;
        END IF;

        first_name := random_word(p_locale, 'first_name_' || gender, person_key || '|first');
        last_name := random_word(p_locale, 'last_name', person_key || '|last');

        num := (p_batch - 1) * p_size + i;
        full_name := random_full_name(p_locale, gender, first_name, last_name, person_key);
        address := random_address(p_locale, person_key || '|address');
        latitude := round(random_latitude(person_key || '|lat')::numeric, 6);
        longitude := round(random_longitude(person_key || '|lon')::numeric, 6);
        height_cm := round(random_normal(person_key || '|height', average_height, height_spread)::numeric, 1);
        weight_kg := round(random_normal(person_key || '|weight', average_weight, weight_spread)::numeric, 1);
        eye_color := random_word(p_locale, 'eye_color', person_key || '|eyes');
        phone := random_phone(p_locale, person_key || '|phone');
        email := random_email(p_locale, first_name, last_name, person_key || '|email');

        RETURN NEXT;
    END LOOP;
END;
$$;
