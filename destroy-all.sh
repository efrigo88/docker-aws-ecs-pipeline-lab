#!/bin/bash

# Exit on error
set -e

# Source environment variables
if [ -f .env ]; then
    echo "📝 Loading environment variables from .env file..."
    export $(cat .env | grep -v '^#' | xargs)
else
    echo "❌ .env file not found!"
    exit 1
fi

# Configuration
AWS_REGION=${AWS_DEFAULT_REGION:-$(aws configure get region)}
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_REPOSITORY="data-pipeline"
S3_BUCKET="processed-pipeline-data"

echo "🗑️  Starting cleanup process..."

# First, empty the S3 bucket
echo "🧹 Emptying S3 bucket..."
aws s3 rm s3://${S3_BUCKET} --recursive --region ${AWS_REGION} || true  # Ignore errors if bucket doesn't exist

# Delete all images from ECR to allow repository deletion
echo "🧹 Cleaning up ECR repository..."
aws ecr batch-delete-image \
    --repository-name ${ECR_REPOSITORY} \
    --image-ids imageTag=latest \
    --region ${AWS_REGION} || true  # Ignore errors if repository doesn't exist

# Destroy Terraform resources
echo "💥 Destroying Terraform resources..."
cd terraform
terraform destroy -auto-approve
cd ..

echo "✅ Cleanup completed successfully!"
echo "All AWS resources have been destroyed."