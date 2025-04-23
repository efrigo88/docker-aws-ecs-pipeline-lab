import os

from sentence_transformers import SentenceTransformer

from .helpers import (
    get_s3_client,
    prepare_json_data,
    save_to_s3,
    get_chroma_client,
    get_collection,
    parse_pdf,
    get_text_content,
    get_chunks,
    get_ids,
    get_metadata,
    run_queries,
)


def main() -> None:
    """Main function to process PDF, store in ChromaDB, and run queries."""
    s3 = get_s3_client()

    bucket = os.getenv("S3_BUCKET")
    if bucket is None:
        raise ValueError("S3_BUCKET environment variable is not set")

    doc = parse_pdf()
    text_content = get_text_content(doc)

    chunks = get_chunks(text_content)
    ids = get_ids(chunks)
    metadatas = get_metadata(chunks, doc)

    model = SentenceTransformer("all-MiniLM-L6-v2")
    embeddings = model.encode(chunks).tolist()

    client = get_chroma_client()
    collection = get_collection(client)

    data = prepare_json_data(chunks, ids, metadatas)
    save_to_s3(s3, data, bucket)

    collection.add(
        ids=ids, documents=chunks, metadatas=metadatas, embeddings=embeddings
    )
    print(f"✅ Stored {len(chunks)} chunks in ChromaDB.")

    run_queries(collection, model)
    print("✅ Done!")


if __name__ == "__main__":
    main()
