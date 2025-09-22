import logging
import os
from typing import Dict, List, Any
from fastmcp import FastMCP
from openai import OpenAI

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

OPENAI_API_KEY = os.environ.get("OPENAI_API_KEY")
VECTOR_STORE_ID = os.environ.get("VECTOR_STORE_ID", "")
openai_client = OpenAI()

server_instructions = "This MCP server provides search and fetch against a vector store."


def create_server():
    mcp = FastMCP(name="Search MCP Server", instructions=server_instructions)

    @mcp.tool()
    async def search(query: str) -> Dict[str, List[Dict[str, Any]]]:
        if not query.strip():
            return {"results": []}
        logger.info(f"Searching for '{query}' in vector store {VECTOR_STORE_ID}")
        response = openai_client.vector_stores.search(vector_store_id=VECTOR_STORE_ID, query=query)
        results = []
        if hasattr(response, "data") and response.data:
            for i, item in enumerate(response.data):
                item_id = getattr(item, "file_id", f"vs_{i}")
                item_filename = getattr(item, "filename", f"Document {i+1}")
                snippet = "Snippet not available"
                if hasattr(item, "content") and item.content:
                    c = item.content[0]
                    if isinstance(c, dict):
                        snippet = c.get("text", "")[:200]
                results.append(
                    {
                        "id": item_id,
                        "title": item_filename,
                        "url": f"https://platform.openai.com/storage/files/{item_id}",
                        "text": snippet,
                    }
                )
        return {"results": results}

    @mcp.tool()
    async def fetch(id: str) -> Dict[str, Any]:
        logger.info(f"Fetching {id}")
        content_response = openai_client.vector_stores.files.content(
            vector_store_id=VECTOR_STORE_ID, file_id=id
        )
        file_info = openai_client.vector_stores.files.retrieve(
            vector_store_id=VECTOR_STORE_ID, file_id=id
        )
        text = ""
        if hasattr(content_response, "data"):
            text = "\n".join([c.text for c in content_response.data if hasattr(c, "text")])
        return {
            "id": id,
            "title": getattr(file_info, "filename", f"Document {id}"),
            "text": text or "No content",
            "url": f"https://platform.openai.com/storage/files/{id}",
            "metadata": getattr(file_info, "attributes", None),
        }

    return mcp


def main():
    if not OPENAI_API_KEY:
        raise ValueError("OPENAI_API_KEY not set")
    server = create_server()
    server.run(transport="sse", host="0.0.0.0", port=8000)


if __name__ == "__main__":
    main()
