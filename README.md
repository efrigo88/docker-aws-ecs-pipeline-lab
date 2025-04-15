# Docker AWS ECS Pipeline Lab

This project demonstrates a complete CI/CD pipeline using Docker, AWS ECS (Elastic Container Service), and Terraform for infrastructure as code. The pipeline processes JSON data and stores it in AWS S3.

## Architecture

- **Application**: Python-based data processing
- **Container**: Docker for containerization
- **Infrastructure**: AWS ECS for container orchestration
- **Storage**: AWS S3 for data storage
- **IaC**: Terraform for infrastructure management
- **Networking**: Custom VPC with public and private subnets

## Prerequisites

- AWS CLI configured
- Docker installed
- Terraform installed
- Python 3.9+

## Infrastructure Components

The project uses Terraform to provision:

- VPC with public and private subnets
- ECS Cluster and Service
- ECR Repository
- IAM Roles and Policies
- CloudWatch Log Groups
- S3 Bucket for data storage

## Project Structure

```
.
├── terraform/             # Infrastructure as Code
│   ├── ecs.tf            # ECS cluster and service configuration
│   ├── ecr.tf            # Container registry configuration
│   ├── networking.tf     # VPC and networking setup
│   ├── iam.tf            # IAM roles and policies
│   ├── s3.tf             # S3 bucket configuration
│   └── variables.tf      # Terraform variables
├── src/
│   └── main.py          # Data processing application
├── Dockerfile           # Container configuration
├── deploy.sh           # Deployment script
├── requirements.txt    # Python dependencies
└── data/              # Data directory
```

## Environment Variables

Required environment variables in `.env`:
- `AWS_ACCESS_KEY_ID`: AWS access key
- `AWS_SECRET_ACCESS_KEY`: AWS secret key
- `AWS_DEFAULT_REGION`: AWS region
- `S3_BUCKET`: Target S3 bucket name

## Local Development Setup

1. Create a Python virtual environment:
```bash
python -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

3. Configure AWS credentials:
```bash
aws configure
```

## Deployment Steps

1. Initialize Terraform:
```bash
cd terraform
terraform init
```

2. Apply Terraform configuration:
```bash
terraform apply
```

3. Build and deploy the container:
```bash
./deploy.sh
```

## Application

The application is a Python script that:
- Reads JSON data from the `data/` directory
- Processes and timestamps the data
- Uploads the processed data to S3
- Runs as a containerized service in ECS

## Docker Configuration

The application is containerized using a Python 3.9 slim base image and includes:
- Python dependencies installation
- Application code and data copying
- Proper platform targeting (linux/amd64)

## Local Testing

To run the application locally:
```bash
python src/main.py
```

## Cleanup

To destroy the infrastructure:
```bash
cd terraform
terraform destroy
```

## Security Notes

- AWS credentials should be managed securely
- IAM roles follow the principle of least privilege
- All sensitive data is managed through environment variables 