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

variable "min_capacity" {
  description = "Minimum number of tasks to run"
  type        = number
  default     = 1
}

variable "max_capacity" {
  description = "Maximum number of tasks to run"
  type        = number
  default     = 3
}

variable "target_cpu_utilization" {
  description = "Target CPU utilization percentage for auto scaling"
  type        = number
  default     = 70
}
