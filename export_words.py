import csv
from faker import Faker

locales = ["en_US", "de_DE"]
categories = ["first_name_male", "first_name_female", "last_name", "prefix_male", "prefix_female", "street_name", "city", "state", "free_email_domain"]

rows = []
for locale in locales:
    fake = Faker(locale)
    fake.seed_instance(1)
    for category in categories:
        make_word = getattr(fake, category)
        values = set()
        for i in range(20000):
            values.add(make_word())
        for value in sorted(values):
            rows.append([locale, category, value])
        print(locale, category, len(values))

with open("data/words.csv", "w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow(["locale", "category", "value"])
    writer.writerows(rows)
