import os
import sys
import mysql.connector
from dotenv import load_dotenv

load_dotenv()

DB_NAME = "indie_game"
SQL_FILE = "src/schema_mysql.sql"
DATA_FILE = "src/sample_data_mysql.sql"

config = {
    "user": os.getenv("MYSQL_USER"),
    "password": os.getenv("MYSQL_PASSWORD"),
    "host": "127.0.0.1",
    "raise_on_warnings": True,
}


def database_or_tables_exist(connection, db_name):
    cursor = connection.cursor()
    try:
        cursor.execute(
            "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = %s",
            (db_name,),
        )
        db_exists = cursor.fetchone() is not None

        if not db_exists:
            return False, []

        cursor.execute(
            "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = %s",
            (db_name,),
        )
        tables = [row[0] for row in cursor.fetchall()]
        return True, tables
    finally:
        cursor.close()


def setup_database(connection, db_name):
    db_exists, existing_tables = database_or_tables_exist(connection, db_name)

    if db_exists:
        if existing_tables:
            print(
                f"Database '{db_name}' already exists with {len(existing_tables)} table(s): "
                f"{', '.join(existing_tables)}"
            )
        else:
            print(f"Database '{db_name}' already exists (currently empty).")

        choice = input(
            f"Do you want to DROP '{db_name}', remove all existing data, and recreate it? [y/N]: "
        ).strip().lower()

        if choice not in ("y", "yes"):
            print("Operation cancelled. Existing database was not modified.")
            sys.exit(0)

    cursor = connection.cursor()
    try:
        if db_exists:
            print(f"Dropping existing database '{db_name}'...")
            cursor.execute(f"DROP DATABASE `{db_name}`")

        print(f"Creating database '{db_name}'...")
        cursor.execute(
            f"CREATE DATABASE `{db_name}` DEFAULT CHARACTER SET 'utf8mb4'"
        )
        cursor.execute(f"USE `{db_name}`")
    except mysql.connector.Error as err:
        print(f"Failed setting up database: {err}")
        sys.exit(1)
    finally:
        cursor.close()


def create_tables(connection, sql_file):
    with open(sql_file, "r", encoding="utf-8") as file:
        ddl_script = file.read()

    cursor = connection.cursor()
    try:
        cursor.execute(ddl_script)

        for result_set in cursor.fetchsets():
            if result_set:
                print(f"Rows returned: {result_set}")

        connection.commit()
        print("SQL file executed successfully.")
    except mysql.connector.Error as err:
        print(f"Error executing SQL file: {err}")
        connection.rollback()
    finally:
        cursor.close()

def add_sample_data(connection, data_file):
    cursor = connection.cursor()
    with open(data_file, "r", encoding="utf-8") as file:
        data_script = file.read()
    try:
        cursor.execute(data_script)
        
        for result_set in cursor.fetchsets():
            if result_set:
                print(f"Rows returned: {result_set}")

        connection.commit()
        print("SQL file executed successfully.")
    except mysql.connector.Error as err:
        print(f"Error executing SQL file: {err}")
        connection.rollback()
    finally:
        cursor.close()


if __name__ == "__main__":
    connection = mysql.connector.connect(**config)
    try:
        setup_database(connection, DB_NAME)
        create_tables(connection, SQL_FILE)
        add_sample_data(connection, DATA_FILE)
    finally:
        connection.close()