from app.core.langchain_model import Model
from langchain_core.prompts import PromptTemplate
from langchain_core.output_parsers import StrOutputParser
from Backend.app.core.vectorestore import VectoreStore
from Backend.app.core.text_splitter import TextSplitter
from langchain.agents import AgentExecutor, create_tool_calling_agent
from app.core.web_search import WebSearch

class ChatbotService:
    def __init__(self):
        self.llm = Model()()
        self.vectore_store = VectoreStore()()
        self.text_splitter = TextSplitter()()

    def assistance_conservation(self, question_user):
        self.question_user = question_user
        self.fill_storage_conservation()

        # Recherche des documents pertinents
        docs_pertinents = self.vectore_store.similarity_search(
            question_user, 
            k=3
        )

        if not docs_pertinents:
            return "Aucun document pertinent trouvé dans la base"

        # Construire le contexte    
        context = "\n\n".join([doc.page_content for doc in docs_pertinents])
    
        # Prompt pour Groq
        template = """Tu es un expert en conservation des aliments. 

        Contexte documentaire :
        {context}

        Question de l'utilisateur : {question_user}

        En te basant sur le contexte fourni, donne des conseils pratiques et précis sur la conservation. Propose plusieurs méthodes adaptées si possible."""

        prompt = PromptTemplate(
                input_variables=["context", "question_user"],
                template=template
        )

        chain = prompt | self.llm | StrOutputParser()

        return chain.invoke({
            "context": context,
            "question_user": question_user
        })

    def fill_storage_conservation(self):
        documents = self.search_context_conservation()

        texts = self.text_splitter.create_documents(documents)
        self.vectore_store.add_documents(texts)

    def search_context_conservation(self):
        template = """Utilise GoogleSearch pour trouver des conseils de conservation utiles récents

        Phrase clé à rechercher : {question_user}"""

        prompt = PromptTemplate(
                input_variables=["question_user"],
                template=template
        ) 

        agent = create_tool_calling_agent(self.llm, WebSearch()(), prompt)

        agent_executor = AgentExecutor(agent=agent, tools=WebSearch, verbose=True)

        result = agent_executor.invoke({
            "question_user": self.question_user
        })

        return result['output']