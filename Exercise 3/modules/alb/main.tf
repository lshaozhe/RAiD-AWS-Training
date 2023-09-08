resource "aws_security_group" "sz-training-alb-sg" {
  name   = "sz-training-alb-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
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
  subnets            = var.public_subnets_ids


  tags = {
    Name        = "sz-exercise3-alb"
    Environment = "production"
  }
}

resource "aws_lb_target_group" "sz-training-alb-tg" {
  name     = "sz-exercise3-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_target_group_attachment" "sz-training-alb-tga" {
  target_group_arn = aws_lb_target_group.sz-training-alb-tg.arn
  target_id        = var.ec2_id
  port             = 80
}

resource "aws_lb_listener" "sz-training-alb-listener" {
  load_balancer_arn = aws_lb.sz-training-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "80"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener_rule" "static" {
  listener_arn = aws_lb_listener.sz-training-alb-listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sz-training-alb-tg.arn

  }

  condition {
    path_pattern {
      values = ["/var/www/html/index.html"]
    }
  }
}
