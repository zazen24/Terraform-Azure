from datetime import timedelta, datetime, timezone
from jose import JWTError, jwt
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from requests import Session
from . import models, schemas, utils
from .database import SessionLocal

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

SECRET_KEY = "09d25e094faa6ca2556c818166b7a9563b93f7099f6f0f4caa6cf63b77c693e7"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 150
    

def access_token(data: dict):
    to_encode = data.copy()
    expire = datetime.now(timezone.utc) + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm= ALGORITHM)
    return encoded_jwt


def verify_access_token(token:str, credentials_exceptption: HTTPException):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        #while decoding, jwt method expects algorithm as a list, so we have to pass it as a list
        id: int = payload.get("user_id")
        if id is None:
            raise credentials_exceptption
        token_data = schemas.TokenData(user_id=id)
    except JWTError:
        raise credentials_exceptption 
    
    return token_data
    
def get_current_user(token: str = Depends(oauth2_scheme)):
    ##The oauth2_scheme dependency will extract the token from the request (e.g., from the Authorization header)
    # and pass it to the token parameter of the current_user function
    credentials_exceptption = HTTPException(status_code=401, detail="Invalid token")
    return verify_access_token(token, credentials_exceptption)  


# def get_current_user(db: Session = Depends(SessionLocal), token: str = Depends(oauth2_scheme)):
#     try:
#         payload = jwt.decode(token, utils.SECRET_KEY, algorithms=[utils.ALGORITHM])
#         email: str = payload.get("sub")
#         if email is None:
#             raise HTTPException(status_code=400, detail="Invalid token")
#         user = db.query(models.User).filter(models.User.email == email).first()
#         if user is None:
#             raise HTTPException(status_code=404, detail="User not found")
#         return user
#     except JWTError:
#         raise HTTPException(status_code=401, detail="Invalid token")