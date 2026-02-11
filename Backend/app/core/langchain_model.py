from langchain_groq import ChatGroq
from app.core.config import settings    

class Model:
    def __init__(self, model: str = "llama-3.3-70b-versatile", temperature: float = 1.0):
        self.model_name = model
        self.temperature = temperature
        self.api_key = settings.groq_api_key

    def __call__(self):
        return ChatGroq(
            model=self.model_name,
            groq_api_key=self.api_key,
            temperature=self.temperature,
            max_tokens=500,
            timeout=None,
            max_retries=2,
        )