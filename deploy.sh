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
IMAGE_TAG="latest"

echo "🚀 Starting deployment process..."

# Create AWS resources first
echo "🛠️  Creating AWS resources..."
cd terraform
terraform init
terraform apply -auto-approve
cd ..

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
echo "📊 Check the ECS service status in the AWS Console"
echo "🔍 Monitor the CloudWatch logs for the ECS task"