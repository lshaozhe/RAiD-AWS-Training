variable "subnet_types" {
  type    = map(string)
  default = { public : 1, private : 2 }
}