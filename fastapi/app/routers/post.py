from fastapi import FastAPI, HTTPException, Depends, Response, status, APIRouter
from .. import models, schemas, utils, oauth2
from ..database import  SessionLocal, get_db
from sqlalchemy.orm import Session
from typing import List


router = APIRouter(
    prefix="/posts",
    tags=["posts"]
)

@router.get("/", response_model=List[schemas.Post])
async def read_post(db: Session = Depends(get_db)):
    # cur.execute("SELECT * FROM posts")
    # posts = cur.fetchall()
    posts = db.query(models.Post).all()
    #print(posts)
    return  posts

@router.get("/{post_id}" , response_model=schemas.Post)
def read_post(post_id: int, db: Session = Depends(get_db)):
    post = db.query(models.Post).filter(models.Post.id == post_id).first()
    if post is None:
        raise HTTPException(status_code=404, detail="Post not found")
    return post

#     # try:
    #     cur.execute("SELECT * FROM posts WHERE id = %s", (post_id,))
    #     post = cur.fetchone()
    #     if post:
    #         return post
    #     else:
    #         raise HTTPException(status_code=404, detail=f"Post with id {post_id} not found")
    # except Exception as e:
   
    #     raise HTTPException(status_code=500, detail="Failed to retrieve post")

    

@router.post("/", status_code=status.HTTP_201_CREATED, response_model=schemas.Post)
def create_post(payload: schemas.PostCreate, db: Session = Depends(get_db), user_id : int = Depends(oauth2.get_current_user)):

    #new_post = models.Post(title=payload.title, content=payload.content, published=payload.published)
    # we have added below line toaccept the payload as dict and now it doesnt matter how many columns are there in db 
    print(user_id)
    new_post = models.Post(**payload.model_dump())
    db.add(new_post)
    db.commit()
    db.refresh(new_post)
    return new_post
#     cur.execute("INSERT INTO posts (title, content, published) VALUES (%s, %s, %s) RETURNING *", (payload.title, payload.content, payload.published))
#     post_new = cur.fetchone()
#     conn.commit()
#     return post_new
 

@router.put("/{post_id}", response_model=schemas.Post)
def update_post(post_id: int, payload: schemas.PostCreate,db: Session = Depends(get_db)):
#     cur.execute("UPDATE posts SET title = %s, content = %s, published = %s WHERE id = %s RETURNING *", (payload.title, payload.content, payload.published, post_id))
#     post_updated = cur.fetchone()
#     conn.commit()
#     return post_updated
    post = db.query(models.Post).filter(models.Post.id == post_id).first()
    if post is None:
        raise HTTPException(status_code=404, detail="Post not found")
    post.title = payload.title
    post.content = payload.content
    post.published = payload.published
    db.commit()
    db.refresh(post)
    return post
      