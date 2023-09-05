output "vpc_id" {
  value = aws_vpc.sz-training-vpc.id
}

output "private_subnet_id" {
  value = aws_subnet.sz-training-subnet["private"].id
}

output "public_subnet_id" {
  value = aws_subnet.sz-training-subnet["public"].id
}

