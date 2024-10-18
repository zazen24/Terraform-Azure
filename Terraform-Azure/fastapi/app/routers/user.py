from fastapi import FastAPI, HTTPException, Depends, Response, status, APIRouter
from .. import models, schemas, utils
from ..database import engine, SessionLocal, get_db
from sqlalchemy.orm import Session
from typing import List



router = APIRouter(
    prefix="/users",
    tags=["users"]
)

@router.post("/", status_code=status.HTTP_201_CREATED, response_model=schemas.UserResponse)
def create_user(payload: schemas.UserBase, db: Session = Depends(get_db)):
    #hashing the password
    hashed_password = utils.hash_func(payload.password)
    payload.password = hashed_password

    new_user = models.User(**payload.model_dump())
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user   

@router.get("/", response_model=List[schemas.UserResponse])
def read_users(db: Session = Depends(get_db)):
    users = db.query(models.User).all()
    return users

@router.get("/{user_id}", response_model=schemas.UserResponse)
def read_user(user_id: int, db: Session = Depends(get_db)):
    user = db.query(models.User).filter(models.User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail=f"User with id: {id} not found")
    
    return user