import sys
import psycopg2
from config import PG_CONFIG, FILE_PATHS, SCHEMAS

# PostgreSQL connection
conn = psycopg2.connect(
    host=PG_CONFIG["host"],
    port=PG_CONFIG["port"],
    database=PG_CONFIG["database"],
    user=PG_CONFIG["user"],
    password=PG_CONFIG["password"]
)

cur = conn.cursor()

p_date = sys.argv[1] 

# CSV file and table
csv_file = FILE_PATHS["fx_rates"]
schema = SCHEMAS["raw"]
table_name = "fx_rates"
target_table = f"{schema}.{table_name}"

# Truncate target table
cur.execute(f"TRUNCATE TABLE {target_table};")
conn.commit()

# Load CSV into PostgreSQL
with open(csv_file, "r") as f:
    cur.copy_expert(
        f"""
        COPY {target_table}
        (fx_rate_date,currency,rate_to_nzd	)
        FROM STDIN WITH CSV HEADER
        """,
        f
    )

conn.commit()

# Log the load date
cur.execute(
    "INSERT INTO audit.etl_load_log(table_name, status) VALUES (%s, %s)",
    ("file:fx_rates", "SUCCESS")
)
conn.commit()

cur.execute(
    f"UPDATE {target_table} SET business_date = %s",
    (p_date,)
)
conn.commit()

cur.close()
conn.close()

print("fx_rates loaded successfully")