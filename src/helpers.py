from typing import List, Dict, Any
from datetime import datetime
import os
import json

import boto3
import chromadb
from chromadb.config import Settings
from docling.datamodel.document import InputDocument
from docling.document_converter import DocumentConverter
from sentence_transformers import SentenceTransformer

from .config import CHUNK_SIZE, SOURCE_PATH, QUERIES


def get_s3_client():
    """Get S3 client."""
    return boto3.client(
        "s3",
        aws_access_key_id=os.getenv("AWS_ACCESS_KEY_ID"),
        aws_secret_access_key=os.getenv("AWS_SECRET_ACCESS_KEY"),
        region_name=os.getenv("AWS_DEFAULT_REGION"),
    )


def prepare_json_data(
    chunks: List[str],
    ids: List[str],
    metadatas: List[Dict[str, Any]],
    source_path: str = SOURCE_PATH,
) -> Dict[str, Any]:
    """Prepare structured data for S3 with all Chroma components."""
    return {
        "source": source_path,
        "timestamp": datetime.now().isoformat(),
        "chunks": [
            {"id": ids[i], "text": chunk, "metadata": metadata}
            for i, (chunk, metadata) in enumerate(zip(chunks, metadatas))
        ],
    }


def save_to_s3(s3_client: boto3.client, data: list[dict], bucket: str):
    """Save data to S3."""
    key = f"{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
    s3_client.put_object(
        Bucket=bucket,
        Key=key,
        Body=json.dumps(data, indent=2),
        ContentType="application/json",
    )
    print(f"Successfully wrote the data to s3://{bucket}/{key}")


def get_chroma_client() -> chromadb.HttpClient:
    """Initialize and return a ChromaDB HTTP client."""
    return chromadb.HttpClient(
        host=os.getenv("CHROMA_HOST", "chroma"),
        port=int(os.getenv("CHROMA_PORT", "8000")),
        settings=Settings(allow_reset=True, anonymized_telemetry=False),
    )


def get_collection(client: chromadb.HttpClient) -> chromadb.Collection:
    """Get or create a ChromaDB collection with retry logic."""
    collection_status = False
    while collection_status is not True:
        try:
            collection = client.get_or_create_collection(name="my_collection")
            collection_status = True
        except chromadb.errors.ChromaError:
            pass
    return collection


def parse_pdf(source_path: str = SOURCE_PATH) -> InputDocument:
    """Parse the PDF document using DocumentConverter."""
    converter = DocumentConverter()
    result = converter.convert(source_path)
    return result.document


def get_text_content(doc: InputDocument) -> List[str]:
    """Extract text content from the document."""
    return [
        text_item.text.strip()
        for text_item in doc.texts
        if text_item.text.strip() and text_item.label == "text"
    ]


def get_chunks(
    text_content: List[str], chunk_size: int = CHUNK_SIZE
) -> List[str]:
    """Split text content into chunks of specified size."""
    chunks = []
    for text in text_content:
        for i in range(0, len(text), chunk_size):
            chunk = text[i : i + chunk_size].strip()
            if chunk:
                chunks.append(chunk)
    if not chunks:
        raise ValueError("No text chunks found in the document.")
    return chunks


def get_ids(chunks: List[str], source_path: str = SOURCE_PATH) -> List[str]:
    """Generate unique IDs for each chunk."""
    return [f"{source_path}_chunk_{i}" for i in range(len(chunks))]


def get_metadata(
    chunks: List[str], doc: InputDocument, source_path: str = SOURCE_PATH
) -> List[Dict[str, Any]]:
    """Generate metadata for each chunk."""
    return [
        {
            "source": source_path,
            "chunk_index": i,
            "title": doc.name,
            "chunk_size": len(chunk),
        }
        for i, chunk in enumerate(chunks)
    ]


def run_queries(
    collection: chromadb.Collection,
    model: SentenceTransformer,
    queries: List[str] = None,
) -> None:
    """Run queries against the collection and print results."""
    if queries is None:
        queries = QUERIES
    for query in queries:
        query_embedding = model.encode(query).tolist()
        results = collection.query(
            query_embeddings=[query_embedding], n_results=3
        )
        print(f"\n❓ Question: {query}")
        print("\n🔍 Top matches:")
        for doc in results["documents"][0]:
            print("-", doc[:200], "...\n")  # Print first 200 characters
        print("-" * 50)
