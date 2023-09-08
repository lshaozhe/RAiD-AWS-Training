output "vpc_id" {
  value = aws_vpc.sz-training-vpc.id
}

output "private_subnet_a_id" {
  value = aws_subnet.sz-training-subnet["private-a"].id
}

output "public_subnet_a_id" {
  value = aws_subnet.sz-training-subnet["public-a"].id
}

output "public_subnet_b_id" {
  value = aws_subnet.sz-training-subnet["public-b"].id
}

