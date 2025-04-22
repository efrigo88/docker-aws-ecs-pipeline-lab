# ECS Configuration
locals {
  # CPU units for the ECS task (1024 units = 1 vCPU)
  task_cpu = 1024

  # Memory for the ECS task in MiB
  task_memory = 2048
}

# ECS Cluster
resource "aws_ecs_cluster" "data_pipeline" {
  name = "data-pipeline-cluster"
}

# ECS Task Definition
resource "aws_ecs_task_definition" "etl_task" {
  family                   = "etl-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = local.task_cpu
  memory                   = local.task_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "etl-container"
      image     = "${aws_ecr_repository.data_pipeline.repository_url}:latest"
      essential = true
      environment = [
        {
          name  = "AWS_REGION"
          value = var.aws_region
        },
        {
          name  = "S3_BUCKET"
          value = aws_s3_bucket.processed-pipeline-data.id
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/etl-task"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}
