from fastapi import FastAPI
from dotenv import load_dotenv
import mysql.connector
import os

load_dotenv()

config = {
    "user": os.getenv("MYSQL_USER"),
    "password": os.getenv("MYSQL_PASSWORD"),
    "host": "127.0.0.1",
    "raise_on_warnings": True,
}

connection = mysql.connector.connect(**config)

app = FastAPI()

@app.get("/games/")
def read_all_games():
    cursor = connection.cursor()
    try:
        results = cursor.execute("SELECT * FROM game")
    except mysql.connector.Error as err:
        print(f"Error executing SQL file: {err}")
        connection.rollback()
    finally:
        cursor.close()
        

@app.get("/games/{game_id}")
def read_game_using_id(item_id: int):
    return 