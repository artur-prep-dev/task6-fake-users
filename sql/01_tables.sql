DROP TABLE IF EXISTS playing_with_neon;

CREATE TABLE IF NOT EXISTS locales (
    code text PRIMARY KEY,
    name text NOT NULL
);

INSERT INTO locales (code, name) VALUES
    ('en_US', 'English (USA)'),
    ('de_DE', 'German (Germany)')
ON CONFLICT (code) DO NOTHING;

CREATE TABLE IF NOT EXISTS words (
    locale text NOT NULL REFERENCES locales(code),
    category text NOT NULL,
    idx integer NOT NULL,
    value text NOT NULL,
    PRIMARY KEY (locale, category, idx)
);

CREATE TABLE IF NOT EXISTS word_counts (
    locale text NOT NULL,
    category text NOT NULL,
    total integer NOT NULL,
    PRIMARY KEY (locale, category)
);
