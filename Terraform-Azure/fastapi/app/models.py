from .database import Base
from sqlalchemy import Column, Integer, String, DateTime, Boolean
import datetime
from sqlalchemy.sql.sqltypes import TIMESTAMP
from sqlalchemy.sql import text

class Post(Base):
    __tablename__ = "posts"


    id = Column(Integer, primary_key=True, index=True, nullable=False,autoincrement=True)
    title = Column(String, nullable=False)
    content = Column(String, nullable=False)
    published = Column(Boolean, server_default='True', nullable=False)
   #  created_at = Column(DateTime, default=lambda: datetime.datetime.now(datetime.timezone.utc))
    created_at = Column(TIMESTAMP(timezone=True),nullable=False, server_default=text('now()'))

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True, nullable=False,autoincrement=True)
    name = Column(String, nullable=False)
    email = Column(String, nullable=False, unique=True)    
    password = Column(String, nullable=False)
    created_at = Column(TIMESTAMP(timezone=True),nullable=False, server_default=text('now()'))

