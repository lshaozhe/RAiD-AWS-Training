// VPC & subnets
resource "aws_vpc" "sz-training-vpc" {
  cidr_block           = "10.0.0.0/20"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "sz-exercise3-vpc"
  }
}

resource "aws_internet_gateway" "sz-training-igw" {
  vpc_id = aws_vpc.sz-training-vpc.id

  tags = {
    Name = "sz-exercise3-igw"
  }
}

resource "aws_egress_only_internet_gateway" "sz-training-eigw" {
  vpc_id = aws_vpc.sz-training-vpc.id

  tags = {
    Name = "sz-exercise3-eigw"
  }
}

resource "aws_subnet" "sz-training-subnet" {
  for_each = var.subnet_types

  vpc_id     = aws_vpc.sz-training-vpc.id
  cidr_block = "10.0.${each.value}.0/24"

  tags = {
    Name = "sz-exercise3-subnet-${each.key}"
  }
}

resource "aws_route_table" "sz-training-route" {
  for_each = var.subnet_types

  vpc_id = aws_vpc.sz-training-vpc.id

  dynamic "route" {
    for_each = each.key == "public" ? [1] : []

    content {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.sz-training-igw.id
    }
  }

  dynamic "route" {
    for_each = each.key == "private" ? [1] : []

    content {
      ipv6_cidr_block        = "::/0"
      egress_only_gateway_id = aws_egress_only_internet_gateway.sz-training-eigw.id
    }
  }

  tags = {
    Name = "sz-exercise3-rt-${each.key}"
  }
}

resource "aws_route_table_association" "subnet_association" {
  for_each       = var.subnet_types
  subnet_id      = aws_subnet.sz-training-subnet[each.key].id
  route_table_id = aws_route_table.sz-training-route[each.key].id
}
