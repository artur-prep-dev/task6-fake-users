import pandas as pd
import psycopg2
import streamlit as st

def run_query(sql, params=None):
    conn = psycopg2.connect(st.secrets["DATABASE_URL"])
    cur = conn.cursor()
    cur.execute(sql, params)
    rows = cur.fetchall()
    columns = []
    for column in cur.description:
        columns.append(column[0])
    conn.close()
    return pd.DataFrame(rows, columns=columns)

st.set_page_config(page_title="Fake Users Generator", layout="wide")
st.title("Fake Users Generator")

locales = run_query("SELECT code, name FROM locales ORDER BY code")
locale_codes = {}
for i in range(len(locales)):
    name = locales["name"][i]
    code = locales["code"][i]
    locale_codes[name] = code

col1, col2 = st.columns(2)
locale_name = col1.selectbox("Locale", list(locale_codes.keys()))
locale = locale_codes[locale_name]
seed = col2.number_input("Seed", min_value=0, value=42, step=1)

if "batch" not in st.session_state:
    st.session_state.batch = 1
    st.session_state.locale = locale
    st.session_state.seed = seed

if st.session_state.locale != locale or st.session_state.seed != seed:
    st.session_state.locale = locale
    st.session_state.seed = seed
    st.session_state.batch = 1

def previous_batch():
    st.session_state.batch = st.session_state.batch - 1

def next_batch():
    st.session_state.batch = st.session_state.batch + 1

col3, col4, col5 = st.columns([2, 2, 5])
col3.button("Previous batch", on_click=previous_batch, disabled=st.session_state.batch == 1)
col4.button("Next batch", on_click=next_batch)

batch = st.session_state.batch
users = run_query("SELECT * FROM generate_users(%s, %s, %s)", (locale, int(seed), batch))

st.subheader("Batch " + str(batch))
st.dataframe(users, hide_index=True)
