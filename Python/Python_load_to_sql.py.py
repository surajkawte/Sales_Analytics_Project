"""
csv_to_sql.py

Professional script to load CSV files from a folder into SQL Server.
Implements TRUNCATE-AND-LOAD to avoid duplicates.
"""

import os
import logging
import pandas as pd
import pyodbc
from urllib.parse import quote_plus
from sqlalchemy import create_engine, text

# CONFIGURATION
SERVER = "enter_your_server_here"
DATA_FOLDER = "C:enter_your_path_here\data"
DB_NAME = "EnterYourDatabaseName"

# Optional: chunk size for bulk insert
CHUNK_SIZE = 1000

#  LOGGER SETUP
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s [%(levelname)s] %(message)s',
    handlers=[logging.StreamHandler()]
)
logger = logging.getLogger(__name__)

# HELPERS
def pick_sqlserver_driver():
    """
    Returns the best available SQL Server ODBC driver installed on the system.
    """
    candidates = ["ODBC Driver 18 for SQL Server", "ODBC Driver 17 for SQL Server", "SQL Server"]
    installed = set(pyodbc.drivers())
    for d in candidates:
        if d in installed:
            return d
    raise RuntimeError(f"No suitable ODBC driver found. Installed: {sorted(installed)}")

def create_database_if_not_exists(engine, db_name: str):
    """
    Creates the database if it does not exist.
    """
    with engine.connect() as conn:
        conn.execute(text(f"IF DB_ID('{db_name}') IS NULL CREATE DATABASE [{db_name}]"))
        logger.info(f"Database '{db_name}' created or already exists.")

def truncate_table_if_exists(conn, table_name: str):
    """
    Truncates the table if it exists in the database.
    """
    conn.execute(text(f"""
        IF OBJECT_ID('{table_name}', 'U') IS NOT NULL
        TRUNCATE TABLE [{table_name}]
    """))
    logger.info(f"Truncated table [{table_name}].")

def load_csv_to_sql(engine, file_path: str, table_name: str):
    """
    Loads a CSV file into a SQL Server table using truncate-and-load mechanism.
    """
    df = pd.read_csv(file_path)
    with engine.connect() as conn:
        truncate_table_if_exists(conn, table_name)
    df.to_sql(
        table_name,
        con=engine,
        if_exists='append',  # append after truncating
        index=False,
        method=None,
        chunksize=CHUNK_SIZE
    )
    logger.info(f"Loaded '{os.path.basename(file_path)}' into table [{table_name}].")

#    MAIN SCRIPT
def main():
    driver = pick_sqlserver_driver()
    driver_enc = quote_plus(driver)

    # Connect to master DB to create target database
    url_master = f"mssql+pyodbc://@{SERVER}/master?driver={driver_enc}&trusted_connection=yes"
    engine_master = create_engine(url_master, isolation_level="AUTOCOMMIT")
    create_database_if_not_exists(engine_master, DB_NAME)

    # Connect to target database
    url_db = f"mssql+pyodbc://@{SERVER}/{DB_NAME}?driver={driver_enc}&trusted_connection=yes"
    engine_db = create_engine(url_db, connect_args={"fast_executemany": True})

    if not os.path.isdir(DATA_FOLDER):
        logger.error(f"Data folder not found: {DATA_FOLDER}")
        return

    csv_files = [f for f in os.listdir(DATA_FOLDER) if f.lower().endswith(".csv")]
    if not csv_files:
        logger.warning(f"No CSV files found in {DATA_FOLDER}")
        return

    for file in csv_files:
        table_name = os.path.splitext(file)[0]
        file_path = os.path.join(DATA_FOLDER, file)
        load_csv_to_sql(engine_db, file_path, table_name)

    logger.info("All CSV files have been loaded successfully.")

if __name__ == "__main__":
    main()
