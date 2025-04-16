#!/bin/bash

# Exit on error
set -e

# Source environment variables
source .env

# Update terraform.tfvars with S3 bucket name from .env
echo "s3_bucket_name = \"$S3_BUCKET\"" > terraform/terraform.tfvars

# Initialize and apply Terraform
cd terraform
terraform init
terraform apply -auto-approve

# Get the API Gateway URL
API_URL=$(terraform output -raw api_gateway_url)

# Configuration
AWS_REGION=${AWS_DEFAULT_REGION:-$(aws configure get region)}
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_REPOSITORY="data-pipeline"
IMAGE_TAG="latest"

echo "🚀 Starting deployment process..."

# Build Docker image
echo "📦 Building Docker image..."
docker buildx build --platform linux/amd64 -t ${ECR_REPOSITORY}:${IMAGE_TAG} .

# Login to ECR
echo "🔑 Logging in to ECR..."
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

# Tag and push Docker image
echo "🏷️  Tagging and pushing Docker image..."
docker tag ${ECR_REPOSITORY}:${IMAGE_TAG} ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY}:${IMAGE_TAG}
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY}:${IMAGE_TAG}

echo "✅ Deployment completed successfully!"
echo "🌐 API Gateway URL: ${API_URL}"
echo "📡 Test the API with: curl -X POST ${API_URL}"
