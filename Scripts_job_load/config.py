# config.py

# PostgreSQL connection details
PG_CONFIG = {
    "host": "localhost",
    "port": "5435",
    "database": "CUST_TXN_DB",
    "user": "postgres",
    "password": "****"
}

# File paths
FILE_PATHS = {
    "customers": r"..\Raw_Data\customers.csv",
    "accounts": r"..\Raw_Data\accounts.csv",
    "fx_rates": r"..\Raw_Data\fx_rates.csv",
    "transactions": r"..\Raw_Data\transactions.csv"
}

# Schema names
SCHEMAS = {
    "raw": "raw"
}