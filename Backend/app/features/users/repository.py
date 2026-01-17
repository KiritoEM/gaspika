from sqlalchemy.orm import Session
from app.models import User
from app.core.utils.hashing import hash_string

class UserRepository:
    def __init__(self, db: Session):
        self.db = db
    
    #create new user
    def create(self, email: str, first_name:str, last_name: str, password: str) -> User:
        user = User(
            first_name = first_name,
            last_name = last_name,
            email = email,
            password= hash_string(password)  
        )
        
        self.db.add(user)
        self.db.commit()
        
        return user
    
    #find if email already exist
    def get_user_by_email(self, email: str) -> User | None:
        user = self.db.query(User).filter(User.email == email).first()
        
        return user
        
     