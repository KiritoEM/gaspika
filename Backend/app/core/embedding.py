from langchain_huggingface.embeddings import HuggingFaceEmbeddings

class Embedding:
    def __init__(self, model: str = "sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2"):
        self.model_name = model

    def __call__(self):
        return HuggingFaceEmbeddings(
            model_name = self.model_name
        )