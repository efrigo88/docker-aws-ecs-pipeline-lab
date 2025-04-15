"""Script to read JSON data and save it to S3."""

import os
import json
import boto3
from datetime import datetime


def main():
    """Main entry point."""
    # Initialize S3 client
    s3 = boto3.client(
        "s3",
        aws_access_key_id=os.getenv("AWS_ACCESS_KEY_ID"),
        aws_secret_access_key=os.getenv("AWS_SECRET_ACCESS_KEY"),
        region_name=os.getenv("AWS_DEFAULT_REGION"),
    )

    # Get bucket name from environment variable
    bucket = os.getenv("S3_BUCKET", "processed-pipeline-data")

    # Read JSON data
    with open("data/data.json", "r", encoding="utf-8") as f:
        data = json.load(f)

    # Save to S3
    key = f"{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
    s3.put_object(
        Bucket=bucket,
        Key=key,
        Body=json.dumps(data, indent=2),
        ContentType="application/json",
    )

    print(f"Successfully wrote clinical notes to s3://{bucket}/{key}")


if __name__ == "__main__":
    main()
