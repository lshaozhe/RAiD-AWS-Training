// VPC & subnets
locals {
  subnet_private_map = {
    for element in var.private_subnet_list :
    element => index(var.private_subnet_list, element)
  }

  subnet_public_map = {
    for element in var.public_subnet_list :
    element => index(var.public_subnet_list, element)
  }

  subnet_all_map = merge(local.subnet_public_map, local.subnet_private_map)
}

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

resource "aws_eip" "sz-training-eip" {
  domain = "vpc"

  tags = {
    Name = "sz-exercise3-eip"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "sz-training-subnet" {
  for_each = local.subnet_all_map

  availability_zone = element(data.aws_availability_zones.available.names, each.value)
  vpc_id            = aws_vpc.sz-training-vpc.id
  cidr_block        = strcontains(each.key, "public") ? "10.0.${each.value + 1}.0/28" : "10.0.${each.value + 1}.128/28"

  tags = {
    Name = "sz-exercise3-subnet-${each.key}"
  }
}

resource "aws_nat_gateway" "sz-training-nat" {
  for_each = local.subnet_private_map

  allocation_id = aws_eip.sz-training-eip.id
  subnet_id     = aws_subnet.sz-training-subnet[each.key].id

  tags = {
    Name = "sz-exercise3-nat"
  }
}

resource "aws_route_table" "sz-training-route" {
  for_each = local.subnet_all_map

  vpc_id = aws_vpc.sz-training-vpc.id

  dynamic "route" {
    for_each = strcontains(each.key, "public") ? [1] : []

    content {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.sz-training-igw.id
    }
  }

  dynamic "route" {
    for_each = strcontains(each.key, "private") ? [1] : []

    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.sz-training-nat[each.key].id
    }
  }

  tags = {
    Name = "sz-exercise3-rt-${each.key}"
  }
}

resource "aws_route_table_association" "subnet_association" {
  for_each       = local.subnet_all_map
  subnet_id      = aws_subnet.sz-training-subnet[each.key].id
  route_table_id = aws_route_table.sz-training-route[each.key].id
}
