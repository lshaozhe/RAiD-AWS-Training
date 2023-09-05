resource "aws_security_group" "sz-training-alb-sg" {
  name   = "sz-training-alb-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 3000
    to_port     = 3000
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
    Name = "sz-exercise3-alb-sg"
  }
}

resource "aws_lb" "sz-training-alb" {
  name               = "sz-training-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sz-training-alb-sg.id]
  subnets            = [var.public_subnet_id]


  tags = {
        Name = "sz-exercise3-alb"
    Environment = "production"
  }
}