CREATE OR REPLACE FUNCTION fill_digits(template text, key text)
RETURNS text
LANGUAGE plpgsql IMMUTABLE
AS $$
DECLARE
    result text := '';
    symbol text;
BEGIN
    IF template IS NULL THEN
        RETURN NULL;
    END IF;
    FOR i IN 1..length(template) LOOP
        symbol := substr(template, i, 1);
        IF symbol = '#' THEN
            result := result || random_int(key || '|' || i, 0, 9);
        ELSE
            result := result || symbol;
        END IF;
    END LOOP;
    RETURN result;
END;
$$;

CREATE OR REPLACE FUNCTION random_phone(p_locale text, key text)
RETURNS text
LANGUAGE plpgsql STABLE
AS $$
DECLARE
    phone_format text;
BEGIN
    phone_format := random_word(p_locale, 'phone_format', key || '|format');
    RETURN fill_digits(phone_format, key || '|digits');
END;
$$;

CREATE OR REPLACE FUNCTION random_address(p_locale text, key text)
RETURNS text
LANGUAGE plpgsql STABLE
AS $$
DECLARE
    result text;
    state text;
BEGIN
    result := random_word(p_locale, 'address_format', key || '|format');
    result := replace(result, '{street}', random_word(p_locale, 'street_name', key || '|street'));
    result := replace(result, '{city}', random_word(p_locale, 'city', key || '|city'));

    state := random_word(p_locale, 'state', key || '|state');
    IF state IS NULL THEN
        state := '';
    END IF;
    result := replace(result, '{state}', state);

    result := replace(result, '{house}', random_int(key || '|house', 1, 300)::text);
    result := replace(result, '{apt}', random_int(key || '|apt', 1, 120)::text);
    result := replace(result, '{zip}', fill_digits('#####', key || '|zip'));
    RETURN result;
END;
$$;

CREATE OR REPLACE FUNCTION email_text(value text)
RETURNS text
LANGUAGE plpgsql IMMUTABLE
AS $$
DECLARE
    result text;
BEGIN
    result := lower(value);
    result := replace(result, 'ä', 'ae');
    result := replace(result, 'ö', 'oe');
    result := replace(result, 'ü', 'ue');
    result := replace(result, 'ß', 'ss');
    result := regexp_replace(result, '[^a-z0-9]', '', 'g');
    RETURN result;
END;
$$;

CREATE OR REPLACE FUNCTION random_email(p_locale text, p_first text, p_last text, key text)
RETURNS text
LANGUAGE plpgsql STABLE
AS $$
DECLARE
    first_part text;
    last_part text;
    result text;
BEGIN
    first_part := email_text(p_first);
    last_part := email_text(p_last);

    result := random_word(p_locale, 'email_format', key || '|format');
    result := replace(result, '{first}', first_part);
    result := replace(result, '{last}', last_part);
    result := replace(result, '{f}', left(first_part, 1));
    result := fill_digits(result, key || '|digits');

    RETURN result || '@' || random_word(p_locale, 'free_email_domain', key || '|domain');
END;
$$;

CREATE OR REPLACE FUNCTION random_full_name(p_locale text, p_gender text, p_first text, p_last text, key text)
RETURNS text
LANGUAGE plpgsql STABLE
AS $$
DECLARE
    result text := '';
BEGIN
    IF random_uniform(key || '|title') < 0.2 THEN
        result := random_word(p_locale, 'prefix_' || p_gender, key || '|title_word') || ' ';
    END IF;

    result := result || p_first;

    IF random_uniform(key || '|middle') < 0.3 THEN
        result := result || ' ' || random_word(p_locale, 'first_name_' || p_gender, key || '|middle_word');
    END IF;

    result := result || ' ' || p_last;
    RETURN result;
END;
$$;
