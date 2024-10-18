from fastapi import FastAPI, HTTPException, Depends, Response, status
from fastapi.params import Body
from typing import Optional , List
from random import randint
import psycopg2
from psycopg.rows import dict_row
from  . import models , schemas, utils
from .database import engine, SessionLocal, get_db
from sqlalchemy.orm import Session
from .routers import post, user, auth


  
models.Base.metadata.create_all(bind=engine) 

app = FastAPI()

app.include_router(post.router)
app.include_router(user.router) 
app.include_router(auth.router)

""" Creating pydantic model for post request """

# while True:
#     try:     
#         conn = psycopg.connect(host="chr2pr2mt464", dbname="fastapi", user="postgres", password="secure1t", row_factory=dict_row)
#         cur = conn.cursor()
#         break
#     except Exception as e:
#         raise HTTPException(status_code=500, detail=f"Database connection failed")
#         print(e)

# my_post = [{"title": "Hello", "content": "World", "id": 1}, {"title": "food", "content": "palak paneer", "id": 2}]

@app.get("/")
def read_root():
    return {"Hello": "Chetan"}


 

    