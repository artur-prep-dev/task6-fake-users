import csv
import tomllib
import psycopg2
from psycopg2.extras import execute_values

with open(".streamlit/secrets.toml", "rb") as f:
    secrets = tomllib.load(f)
database_url = secrets["DATABASE_URL"]

rows = []
for path in ["data/words.csv", "data/manual_words.csv"]:
    with open(path, encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            rows.append(row)

counters = {}
words = []
for row in rows:
    key = row["locale"] + "|" + row["category"]
    if key not in counters:
        counters[key] = 0
    idx = counters[key]
    counters[key] = counters[key] + 1
    words.append((row["locale"], row["category"], idx, row["value"]))

conn = psycopg2.connect(database_url)
cur = conn.cursor()

cur.execute("DELETE FROM words")
execute_values(cur, "INSERT INTO words (locale, category, idx, value) VALUES %s", words, page_size=1000)

cur.execute("DELETE FROM word_counts")
cur.execute("INSERT INTO word_counts (locale, category, total) SELECT locale, category, COUNT(*) FROM words GROUP BY locale, category")

conn.commit()
conn.close()
print("Loaded", len(words), "words")
