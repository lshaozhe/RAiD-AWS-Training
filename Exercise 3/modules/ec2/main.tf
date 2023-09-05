resource "aws_security_group" "sz-training-ec2-sg" {
  name   = "sz-training-ec2-sg"
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
    Name = "sz-exercise3-ec2-sg"
  }
}

resource "aws_instance" "sz-training-ec2" {
  ami                         = "ami-0464f90f5928bccb8"
  instance_type               = "t2.micro"
  subnet_id                   = var.private_subnet_id
  vpc_security_group_ids      = [aws_security_group.sz-training-ec2-sg.id]
  associate_public_ip_address = true

  user_data = <<-EOL
      #!/bin/bash
      sudo yum update -y
      sudo yum install -y httpd
      sudo systemctl start httpd
      sudo systemctl enable httpd
  EOL

  depends_on = [
    aws_security_group.sz-training-ec2-sg
  ]

  tags = {
    Name = "sz-exercise3-ec2"
  }
}