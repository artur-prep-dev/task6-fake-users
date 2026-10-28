import pandas as pd
import psycopg2
import streamlit as st

def run_query(sql, params=None):
    conn = psycopg2.connect(st.secrets["DATABASE_URL"])
    cur = conn.cursor()
    cur.execute(sql, params)
    columns = [d[0] for d in cur.description]
    rows = cur.fetchall()
    conn.close()
    return pd.DataFrame(rows, columns=columns)

st.title("Fake Users Generator")
st.dataframe(run_query("SELECT 'Hello' as message, now() as time"))