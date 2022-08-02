provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {}
//changes to infra
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.77.0"

  name                 = var.project_name
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_db_subnet_group" "rds_subnet" {
  name       = var.project_name
  subnet_ids = module.vpc.public_subnets

  tags = {
    Name = var.project_name
  }
}

##   change made here 
resource "aws_security_group" "rds" {
  name   = var.project_name
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.project_name
  }
}

resource "aws_db_parameter_group" "db_parameters" {
  name   = var.project_name
  family = "postgres13"

  parameter {
    name  = "log_connections"
    value = "1"
  }
}

resource "aws_db_instance" "db_instance" {
  identifier             = var.project_name
  instance_class         = "db.t3.small"
  allocated_storage      = 5
  engine                 = "postgres"
  engine_version         = var.engine_version
  username               = "edu"
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.db_parameters.name
  publicly_accessible    = true
  skip_final_snapshot    = true
  apply_immediately = true
}
