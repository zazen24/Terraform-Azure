from fastapi import FastAPI, HTTPException, Depends, Response, status, APIRouter
from sqlalchemy.orm import Session
from fastapi.security import OAuth2PasswordRequestForm

from .. import database,models, schemas, utils, oauth2

router = APIRouter(tags=["auth"])

@router.post("/login", response_model=schemas.Token)
#def login(user_creds: schemas.UserLogin, db: Session = Depends(database.get_db)):
def login(user_creds: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(database.get_db)):
    user = db.query(models.User).filter(models.User.email == user_creds.username).first()
    if not user:
        raise HTTPException(status_code=403, detail="Invalid Credentials")
    if not utils.verify_password(user_creds.password, user.password):
        raise HTTPException(status_code=403, detail="Invalid Credentials")
    #####create and return access token
    access_token = oauth2.access_token(data={"user_id": user.id})
    # response.set_cookie(key="access_token", value=access_token)
    return ({"access_token": access_token, "token_type": "bearer"})
