variable "region" {
  default     = "us-east-2"
  description = "AWS region"
}

variable "db_password" {
  description = "RDS root user password"
  sensitive   = true
}

variable "project_name" {
  default     = "project1"
  description = "This name with be given to the RDS instance"
}

variable "engine" {
  default     = "postgres"
  description = "Engine type of RDS instance"
}