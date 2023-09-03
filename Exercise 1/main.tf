// Step 1: configure VPC and Subnets
resource "aws_vpc" "sz-training-vpc" {
  cidr_block           = "10.0.0.0/20"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "sz-exercise1-vpc"
  }
}

resource "aws_subnet" "sz-training-subnet-public" {
  vpc_id     = aws_vpc.sz-training-vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "sz-exercise1-subnet-public"
  }
}

resource "aws_internet_gateway" "sz-training-igw" {
  vpc_id = aws_vpc.sz-training-vpc.id

  tags = {
    Name = "sz-exercise1-igw"
  }
}

resource "aws_route_table" "sz-training-route-public" {
  vpc_id = aws_vpc.sz-training-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sz-training-igw.id
  }

  tags = {
    Name = "sz-exercise1-rt"
  }
}

resource "aws_route_table_association" "sz-training-route-association-public" {
  subnet_id      = aws_subnet.sz-training-subnet-public.id
  route_table_id = aws_route_table.sz-training-route-public.id
}

// Step 2: Create ec2 instance
resource "aws_security_group" "sz-training-ec2-sg" {
  name        = "sz-training-ec2-sg"
  description = "Allow inbound for exercise 1 ec2"
  vpc_id      = aws_vpc.sz-training-vpc.id

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
    Name = "sz-exercise1-sg"
  }
}

resource "aws_instance" "sz-training-ec2" {
  ami                         = "ami-0464f90f5928bccb8"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.sz-training-subnet-public.id
  vpc_security_group_ids      = [aws_security_group.sz-training-ec2-sg.id]
  associate_public_ip_address = true

  user_data = <<-EOL
      #!/bin/bash
      sudo yum update -y
      sudo yum install -y httpd
      sudo sed -i 's/Listen 80/Listen 3000/' /etc/httpd/conf/httpd.conf
      echo "<html><body><h1>Hello, world!</h1></body></html>" > /var/www/html/index.html
      sudo systemctl start httpd
      sudo systemctl enable httpd
  EOL

  depends_on = [
    aws_security_group.sz-training-ec2-sg
  ]

  tags = {
    Name = "sz-exercise1-ec2"
  }
}

output "ec2_public_dns" {
  description = "Public DNS of the EC2 instance"
  value       = aws_instance.sz-training-ec2.public_dns
}

output "ec2_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.sz-training-ec2.public_ip
}
