terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.79.0"
    }
  }
}

# Configure the AWS provider

provider "aws" {
  region = "${var.region}"
  
}

# ~~~~~~~~~~~~~~~~~~~~~ Getting the ECS Cluster ~~~~~~~~~~~~~~~~~~~~~~~

data "aws_ecs_cluster" "cluster" {
    cluster_name = var.cluster_name
  
}


# ~~~~~~~~~~~~~~~~~~~~~ Getting network configuration ~~~~~~~~~~~~~~~~~~~~~~~

data "aws_vpc" "project_vpc" {
    filter {
      name = "tag:Project"
      values = ["${var.project_name}"]
    }
}

data "aws_security_group" "app_sg" {
    vpc_id = data.aws_vpc.project_vpc.id
    name = "${var.app_name}-sg"
  
}
data "aws_subnet" "public1" {
  filter {
    name   = "tag:Name"
    values = ["${var.project_name}-public-us-east-2a"]
  }
}
data "aws_subnet" "public2" {
  filter {
    name   = "tag:Name"
    values = ["${var.project_name}-public-us-east-2b"]
  }
}


# ~~~~~~~~~~~~~~~~~~~~~ Getting LoadBalancer ~~~~~~~~~~~~~~~~~~~~~~~

data "aws_alb" "app_lb" {
    name = "${var.app_name}-lb" 
}

# ~~~~~~~~~~~~~~~~ Getting target Groups~~~~~~~~~~~~~~

data "aws_alb_target_group" "app_tg" {
    name = "${var.app_name}-targets-group"
}

# ~~~~~~~~~~~~~~~~ Getting ecr repository~~~~~~~~~~~~~~

data "aws_ecr_repository" "front_repo" {
    name = "${var.app_name}-repo"
}

data "aws_iam_role" "execution_role" {
  name = "${var.project_name}-ecs-execution-role"
}



# ~~~~~~~~~~~~ Creating ECS Task Definition for the app services~~~~~~~~~

resource "aws_ecs_task_definition" "app_task_definition" {
    family = var.app_name
    network_mode = "awsvpc"
    execution_role_arn = data.aws_iam_role.execution_role.arn
    requires_compatibilities = ["FARGATE"]
    cpu = var.cpu
    memory = var.memory
    container_definitions = <<TASK_DEFINITION
    [
        {
            "name": "${var.app_name}",
            "image": "${data.aws_ecr_repository.front_repo.repository_url}:${var.image_tag}",
            "essential": true,
            "cpu": ${var.cpu},
            "memory": ${var.memory},
            "portMappings": [
                {
                    "containerPort": ${var.app_port},
                    "hostPort": ${var.app_port}
                }
            ],
            "environment": [
                {
                    "name": "REACT_APP_API_URL",
                    "value": "http://${data.aws_alb.backend_lb.dns_name}:${var.app_port}/"
                }
            ]
        }
    ]
    TASK_DEFINITION
    runtime_platform {
      operating_system_family = "LINUX"
      cpu_architecture = "X86_64"
    }
}

resource "aws_ecs_service" "app_svc" {
    name = var.app_name
    cluster = data.aws_ecs_cluster.cluster.id
    launch_type = "FARGATE"
    task_definition = aws_ecs_task_definition.app_task_definition.arn
    desired_count = 4

    network_configuration {
      security_groups = [data.aws_security_group.app_sg.id ]
      subnets = [data.aws_subnet.public1.id, data.aws_subnet.public2.id]
      assign_public_ip = true
    }

    load_balancer {
      target_group_arn = data.aws_alb_target_group.app_tg.id
      container_name = var.app_name
      container_port = var.app_port
    }
  
}

# ~~~~~~~~~~~~~~~~~~~~~~ Output the URLs of the services ~~~~~~~~~~~~~~~~~~~~


output "app_url" {
  value = "http://${data.aws_alb.app_lb.dns_name}:${var.app_port}"
  description = "The URL of the app service."
}
