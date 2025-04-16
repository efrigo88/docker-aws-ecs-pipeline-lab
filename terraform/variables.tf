# Variables
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "docker-aws-pipeline-lab"
}

variable "task_cpu" {
  description = "CPU units for the ECS task (1024 units = 1 vCPU)"
  type        = number
  default     = 1024
}

variable "task_memory" {
  description = "Memory for the ECS task in MiB"
  type        = number
  default     = 2048
}
