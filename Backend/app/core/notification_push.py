from pathlib import Path

import httpx
from google.oauth2 import service_account
import google.auth.transport.requests
from app.core.config import settings    

_SCOPES = ["https://www.googleapis.com/auth/firebase.messaging"]

def get_authorization_token():
    creds = service_account.Credentials.from_service_account_file(Path(__file__).resolve().parents[2] / settings.firebase_creds_path, scopes=_SCOPES)
    creds.refresh(google.auth.transport.requests.Request())
    
    return creds.token

async def send_android_notification(
    fcm_token: str, 
    title: str,
    body: str,
    data
):
    url = (f"https://fcm.googleapis.com/v1/projects/"
           f"{settings.firebase_project_id}/messages:send")
    payload = {"message": {
        "token": fcm_token,
        "notification": {"title": title, "body": body},
        "data": data,
        "android": {"priority": "high",
                    "notification": {"channel_id": "default"}},
    }}
    
    async with httpx.AsyncClient() as c:
        r = await c.post(url, json=payload, timeout=10,
            headers={"Authorization": f"Bearer {get_authorization_token()}"})
        
        r.raise_for_status()
        return r.json()