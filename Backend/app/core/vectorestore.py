from langchain_chroma import Chroma
from app.core.embedding import Embedding

class VectoreStore:
    def __init__(self, collection_name: str = "conservation_aliments", persist_directory: str = "./db_conservation"):
        self.collection_name = collection_name
        self.persist_directory = persist_directory

    def __call__(self):
        return Chroma(
            collection_name=self.collection_name,
            embedding_function=Embedding()(),
            persist_directory=self.persist_directory
        )