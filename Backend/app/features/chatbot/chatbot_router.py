from fastapi import APIRouter

from .chatbot_service import ChatbotService

chatbot_router = APIRouter(prefix="/chatbot", tags=["conversation conservation"])

_service = ChatbotService()


@chatbot_router.post("/conversation")
async def response_conservation(question: str):
    return _service.assistance_conservation(question)