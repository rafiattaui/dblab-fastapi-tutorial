from fastapi import FastAPI, HTTPException, status, Response, Request
from fastapi.responses import HTMLResponse
from fastapi.templating import Jinja2Templates
from pydantic import BaseModel
from dotenv import load_dotenv
from src.init_db import config
from pwdlib import PasswordHash
import mysql.connector
import uvicorn

load_dotenv()

connection = mysql.connector.connect(database="indie_game", **config)
password_hasher = PasswordHash.recommended()

### Route Models for Serialization
class CreateDeveloper(BaseModel):
    email: str
    username: str
    password: str
    payout_account: str

### Route Logic
app = FastAPI()
templates = Jinja2Templates(directory="src/templates")

# Helper function to avoid duplicating the SQL query logic
def fetch_all_games_from_db():
    cursor = connection.cursor(dictionary=True)
    try:
        cursor.execute("SELECT * FROM game")
        return cursor.fetchall()
    except mysql.connector.Error as err:
        connection.rollback()
        raise HTTPException(status_code=500, detail=str(err))
    finally:
        cursor.close()

def fetch_all_developers_from_db():
    cursor = connection.cursor(dictionary=True)
    try:
        cursor.execute("SELECT * FROM developer")
        return cursor.fetchall()
    except mysql.connector.Error as err:
        connection.rollback()
        raise HTTPException(status_code=500, detail=str(err))
    finally:
        cursor.close()

# Original JSON Route
@app.get("/games/")
def read_all_games():
    return fetch_all_games_from_db()

# New HTML Route
@app.get("/html/games/", response_class=HTMLResponse)
def read_all_games_html(request: Request):
    rows = fetch_all_games_from_db()
    return templates.TemplateResponse(
        request=request, 
        name="games.html", 
        context={"games": rows}
    )

@app.get("/games/{item_id}")
def read_game_using_id(item_id: int):
    cursor = connection.cursor(dictionary=True)
    try:
        cursor.execute("SELECT * FROM game where game_id = %s", (item_id,))
        rows = cursor.fetchall()
        return rows
    except mysql.connector.Error as err:
        connection.rollback()
        raise HTTPException(status_code=500, detail=str(err))
    finally:
        cursor.close()

# Original JSON Route
@app.get("/developer/")
def read_all_developer():
    return fetch_all_developers_from_db()

# New HTML Route
@app.get("/html/developer/", response_class=HTMLResponse)
def read_all_developer_html(request: Request):
    rows = fetch_all_developers_from_db()
    return templates.TemplateResponse(
        request=request,
        name="developers.html",
        context={"developers": rows}
    )

@app.post("/add/developer/", status_code=status.HTTP_201_CREATED)
def add_new_developer(body: CreateDeveloper):
    hashed_pw = password_hasher.hash(body.password)
    cursor = connection.cursor(dictionary=True)
    try:
        cursor.execute(
            """
            INSERT INTO Developer (email, username, hashed_password, payout_account)
            VALUES (%s, %s, %s, %s)
            """,
            (body.email, body.username, hashed_pw, body.payout_account),
        )
        connection.commit()  # save the row

        return {
            "developer_id": cursor.lastrowid,
            "email": body.email,
            "username": body.username,
            "payout_account": body.payout_account,
        }
    except mysql.connector.IntegrityError as err:
        connection.rollback()
        raise HTTPException(status_code=409, detail=f"Developer already exists: {err.msg}")
    except mysql.connector.Error as err:
        connection.rollback()
        raise HTTPException(status_code=500, detail=str(err))
    finally:
        cursor.close()

@app.delete("/delete/developer/{dev_id}")
def delete_developer_with_id(dev_id: int):
    cursor = connection.cursor(dictionary=True)
    try:
        cursor.execute("DELETE FROM Developer WHERE developer_id = %s", (dev_id,))
        connection.commit()
        return Response(status_code=status.HTTP_200_OK)
    except mysql.connector.Error as err:
        connection.rollback()
        raise HTTPException(status_code=500, detail=str(err))
    finally:
        cursor.close()