from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

#SQLALCHEMY_DATABASE_URL = "sqlite:///./sql_app.db"
##SQLALCHEMY_DATABASE_URL = "postgresql://postgresql:Maverick12345!@34.132.89.61/fastapi"

with open('/etc/secrets/POSTGRES-HOST', 'r') as f:
    postgres_host = f.read().strip()

with open('/etc/secrets/POSTGRES-USER', 'r') as f:
    postgres_user = f.read().strip()

with open('/etc/secrets/POSTGRES-PASSWORD', 'r') as f:
    postgres_password = f.read().strip()

with open('/etc/secrets/POSTGRES-DB', 'r') as f:
    postgres_db = f.read().strip()

with open('/etc/secrets/POSTGRES-PORT', 'r') as f:
    postgres_port = f.read().strip()

# Construct the SQLAlchemy Database URL dynamically
SQLALCHEMY_DATABASE_URL = f"postgresql://{postgres_user}:{postgres_password}@{postgres_host}:{postgres_port}/{postgres_db}"


engine = create_engine(SQLALCHEMY_DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()

# Dependency
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

        