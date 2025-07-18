
# ~~~~~~~~~~~~~~~~ Create a Load Balancer for the app ~~~~~~~~~~~~~~~~

resource "aws_lb" "app_lb" {
  name            = "${var.app_name}-lb"
  subnets         = [module.vpc.public_subnets[0], module.vpc.public_subnets[1]]
  security_groups = [aws_security_group.app_sg.id] 
}


# ~~~~~~~~~~~~~~~~ Create a target Group for the app ~~~~~~~~~~~~~

resource "aws_lb_target_group" "app_target_group" {

  name        = "${var.app_name}-targets-group"
  port        = var.app_port
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"

}

# ~~~~~~~~~~~~~~~~ Create a listener for the app ~~~~~~~~~~~~~

resource "aws_lb_listener" "app_listener" {

  load_balancer_arn = aws_lb.app_lb.arn
  port              = var.app_port
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_target_group.arn
  }
}

# ~~~~~~~~~~~~~~~~~~ Create ECS EXECUTION Role ~~~~~~~~~~~~~~~~~~~~

module "ecs_execution_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"

  create_role = true

  role_requires_mfa = false

  role_name = "${var.project_name}-ecs-execution-role"

  trusted_role_services = [
    "ecs-tasks.amazonaws.com"
  ]

  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
     "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess",
  ]
}

# ~~~~~~~~~~~~~~~~~~~~~ Creating ECS Cluster ~~~~~~~~~~~~~~~~~~~~~~~

resource "aws_ecs_cluster" "cluster" {
  name = var.cluster_name
}

# ~~~~~~~~ Create the ECR Repository for the app ~~~~~~~~~

resource "aws_ecr_repository" "repository-app" {
  name = "${var.app_name}-repo"

  image_scanning_configuration {
    scan_on_push = false
  }
  
  force_delete = true
}



output "INFO" {
  value = "AWS Resources  has been provisioned. Repo link: ${aws_ecr_repository.repository-app.repository_url}"
}
