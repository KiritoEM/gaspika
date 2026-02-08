from langchain_google_genai import ChatGoogleGenerativeAI

class Model:
    def __init__(self, model: str = "gemini-1.5-flash", temperature: float = 0.7):
        self.model_name = model
        self.temperature = temperature
        self.api_key = "AIzaSyAG9o_IfOLLaOM1PbQBTTwTTHEIaFFqwfM"

    def __call__(self):
        return ChatGoogleGenerativeAI(
            model=self.model_name,
            google_api_key=self.api_key,
            temperature=self.temperature
        )