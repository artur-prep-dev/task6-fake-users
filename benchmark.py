import time
import tomllib
import psycopg2

with open(".streamlit/secrets.toml", "rb") as f:
    secrets = tomllib.load(f)
database_url = secrets["DATABASE_URL"]

conn = psycopg2.connect(database_url)
cur = conn.cursor()

cur.execute("SELECT num, full_name, phone FROM generate_users('en_US', 42, 1)")
print("Check, first users for en_US, seed 42, batch 1:")
for row in cur.fetchall()[:3]:
    print(row)

users = 10000
for locale in ["en_US", "de_DE"]:
    start = time.time()
    cur.execute("SELECT * FROM generate_users(%s, %s, %s, %s)", (locale, 1, 1, users))
    rows = cur.fetchall()
    seconds = time.time() - start
    print(locale + ":", len(rows), "users in", round(seconds, 2), "seconds =", round(len(rows) / seconds), "users/second")

conn.close()
