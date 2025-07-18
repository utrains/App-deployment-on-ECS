# ~~~~~~~~~~~ Security group for the app LoadBalancer ~~~~~~~~~~

resource "aws_security_group" "app_sg" {

  name        = "${var.app_name}-sg"
  description = "Security group for ${var.app_name} ecs"
  vpc_id      = module.vpc.vpc_id
  ingress {
    description = "allows connection from the internet"
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "${var.app_name}-sg"
  }
}