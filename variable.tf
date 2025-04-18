variable "aws_region" {
  description = "AWS region to deploy resources"
  default     = "ap-south-1" # Change as needed
}
variable "Project" {
  type    = string
  default = "CI/CD"
}
variable "env" {
  type    = string
  default = "test"
}
variable "open-ports" {
  type        = list(number)
  description = "list of ports"
  default     = [22, 80, 8080]
}
variable "image_id" {
  default     = "ami-0e35ddab05955cf57" # provide ami id
  description = "The id of the machine image (AMI) to use for the server."
}
variable "vpc_id" {
  type    = string
  default = "vpc-07471b334ba603932"
}
variable "subnet_id" {
  type    = string
  default = "subnet-0deac80ded4f54e3e"
}