from langchain_core.tools import Tool
from langchain_google_community import GoogleSearchAPIWrapper

class WebSearch:
    def __init__(self):
        self.search = GoogleSearchAPIWrapper

    def top_results(self, query):
        return self.search.results(query, 5)

    def __call__(self):
        return Tool(
            name="Google Search",
            description="Searches Google for recent results",
            func=self.top_results
        )