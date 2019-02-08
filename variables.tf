variable "access_key" {}
variable "secret_key" {}
variable "region" {
    default = "us-east-1"
}

variable "ec2_ami" {
    default = "ami-0ac019f4fcb7cb7e6"
}
variable "ec2_type" {
    default = "t2.micro"
}
variable "ec2_count" {
    default = "5"
}
variable "project" {
    default = "terraform_demo"
}