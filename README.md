# AWS ETL Pipeline with API Gateway, Lambda, and ECS

This project implements a serverless ETL (Extract, Transform, Load) pipeline using AWS services. It provides an HTTP API endpoint that triggers an ETL process, which runs as an ECS task and saves data to S3.

## Architecture

The pipeline consists of the following components:

- **API Gateway**: HTTP API endpoint that accepts POST requests
- **Lambda Function**: Triggers the ETL process when the API is called
- **ECS Task**: Runs the actual ETL process in a container
- **S3 Bucket**: Stores the processed data
- **ECR Repository**: Stores the Docker image for the ETL process
- **VPC & Networking**: Private subnets for ECS tasks with NAT Gateway for internet access

## Prerequisites

- AWS CLI configured with appropriate credentials
- Docker installed
- Terraform installed
- AWS account with sufficient permissions

## Project Structure

```
.
├── build/                    # Docker build context
│   ├── Dockerfile           # Container definition
│   └── etl_script.py        # ETL process implementation
├── terraform/               # Infrastructure as Code
│   ├── api.tf              # API Gateway configuration
│   ├── ecr.tf              # ECR repository
│   ├── ecs.tf              # ECS cluster and task definition
│   ├── iam.tf              # IAM roles and policies
│   ├── lambda.tf           # Lambda function
│   ├── networking.tf       # VPC and networking
│   ├── provider.tf         # Terraform provider
│   ├── s3.tf              # S3 bucket
│   └── variables.tf        # Terraform variables
├── deploy.sh               # Deployment script
├── destroy-all.sh          # Cleanup script
├── .env.example           # Example environment variables
└── README.md              # This file
```

## Setup and Deployment

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd <repository-directory>
   ```

2. **Set up environment variables**
   - Copy the example environment file:
     ```bash
     cp .env.example .env
     ```
   - Edit the `.env` file with your AWS configuration:
     ```
     # AWS Configuration
     AWS_DEFAULT_REGION=eu-west-1
     
     # Optional: Override default values
     # AWS_ACCESS_KEY_ID=your_access_key
     # AWS_SECRET_ACCESS_KEY=your_secret_key
     # AWS_SESSION_TOKEN=your_session_token  # If using temporary credentials
     ```
   - Note: If you have AWS CLI configured, you don't need to set AWS credentials in the .env file

3. **Make scripts executable**
   ```bash
   chmod +x deploy.sh destroy-all.sh
   ```

4. **Deploy the infrastructure**
   ```bash
   ./deploy.sh
   ```
   This will:
   - Create all AWS resources using Terraform
   - Build and push the Docker image to ECR
   - Output the API Gateway URL

## Testing the Pipeline

1. **Get the API Gateway URL**
   After deployment, the URL will be displayed in the output. You can also get it with:
   ```bash
   cd terraform && terraform output api_gateway_url
   ```

2. **Trigger the ETL process**
   ```bash
   curl -X POST <api-gateway-url>
   ```

3. **Monitor the process**
   - Check Lambda logs in CloudWatch: `/aws/lambda/trigger-etl`
   - Check ECS task logs in CloudWatch: `/ecs/etl-task`
   - Check the S3 bucket for output files

## Cleanup

To destroy all resources and clean up:
```bash
./destroy-all.sh
```
This will:
- Empty the S3 bucket
- Delete the ECR repository images
- Destroy all Terraform resources

## Components Details

### API Gateway
- HTTP API endpoint at `/trigger-etl`
- Accepts POST requests
- Integrates with Lambda function

### Lambda Function
- Written in Python
- Triggers ECS task
- Handles error cases
- Logs to CloudWatch

### ECS Task
- Runs in Fargate mode
- Containerized ETL process
- Writes output to S3
- Runs in private subnets

### S3 Bucket
- Stores ETL output files
- JSON format with timestamp
- Named `processed-pipeline-data`

### Networking
- VPC with public and private subnets
- NAT Gateway for private subnet internet access
- Security groups for ECS tasks

## Troubleshooting

1. **Lambda not triggering ECS task**
   - Check Lambda logs in CloudWatch
   - Verify IAM permissions
   - Check environment variables

2. **ECS task failing**
   - Check ECS task logs in CloudWatch
   - Verify container image exists in ECR
   - Check task definition configuration

3. **S3 upload issues**
   - Verify IAM permissions
   - Check S3 bucket policy
   - Verify network connectivity

## Security Considerations

- ECS tasks run in private subnets
- No public IP addresses for tasks
- IAM roles with least privilege
- S3 bucket with appropriate access controls

## Cost Considerations

- Fargate tasks are billed by the second
- S3 storage costs apply
- API Gateway and Lambda have free tier limits
- NAT Gateway has hourly costs

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

[Add your license here] 