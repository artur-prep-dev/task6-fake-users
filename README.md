# Fake Users Generator

App: https://task6-fake-users.streamlit.app

All data was made by SQL functions in PostgreSQL. Same locale + seed + batch = same users.

## Usage

```sql
SELECT * FROM generate_users('en_US', 42, 1);
```

## Functions

| Function | Arguments | How it works |
|---|---|---|
| `random_uniform` | key | md5 of the key turned into a number from 0 to 1 |
| `random_int` | key, min, max | random integer from min to max |
| `random_normal` | key, mean, std | Box-Muller: two random numbers make one normal number |
| `random_word` | locale, category, key | random word from the `words` table |
| `random_latitude` | key | `asin(2u - 1)`, so points are uniform on the sphere |
| `random_longitude` | key | `360u - 180` |
| `fill_digits` | template, key | every `#` becomes a random digit |
| `random_phone` | locale, key | random phone format + digits |
| `random_address` | locale, key | random address format + street, city, house, zip |
| `email_text` | text | `Müller` -> `mueller` |
| `random_email` | locale, first, last, key | name + digits + domain |
| `random_full_name` | locale, gender, first, last, key | title (20%) + first name + middle name (30%) + last name |
| `generate_users` | locale, seed, batch, size | table of users |

Key of a user: `locale|seed|batch|number`.

Height and weight use `random_normal`: men 178 ± 7 cm, women 165 ± 6 cm.

Benchmark (python benchmark.py, 10 000 users): en_US 2774 users/second, de_DE 2454 users/second.