import tomllib
import psycopg2

with open(".streamlit/secrets.toml", "rb") as f:
    secrets = tomllib.load(f)
database_url = secrets["DATABASE_URL"]

files = ["01_tables.sql", "02_random.sql", "03_words_and_geo.sql", "04_person_parts.sql", "05_generate_users.sql"]

conn = psycopg2.connect(database_url)
cur = conn.cursor()
for name in files:
    with open("sql/" + name, encoding="utf-8") as f:
        sql = f.read()
    cur.execute(sql)
    print("Done:", name)
conn.commit()
conn.close()
print("All tables and functions are created")
