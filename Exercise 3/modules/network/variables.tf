variable "public_subnet_list" {
  type    = list(string)
  default = ["public-a", "public-b"]
}

variable "private_subnet_list" {
  type    = list(string)
  default = ["private-a"]
}