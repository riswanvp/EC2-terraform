terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>2.70"
    }
  }
  # backend "s3" {
  #    bucket = "terraform-statef-files"
  #    key    = "Test-Ec2/terraform.tfstate"
  #    region = var.aws_region
  # }
}
provider "aws" {
  region = var.aws_region

}

resource "aws_key_pair" "deployer" {
  key_name   = "Jenkins-key"
  public_key = file("./Jenkins-key.pub")
}

resource "aws_security_group" "allow-all" {
  name   = "${var.Project}-${var.env}-SG"
  vpc_id = var.vpc_id
}
resource "aws_security_group_rule" "inbound" {
  type              = "ingress"
  count             = 3
  security_group_id = aws_security_group.allow-all.id
  protocol          = "tcp"
  from_port         = var.open-ports[count.index]
  to_port           = var.open-ports[count.index]
  cidr_blocks       = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "outbound" {
  type              = "egress"
  from_port         = "0"
  to_port           = "0"
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.allow-all.id
}

resource "aws_instance" "Jenkins-vm" {
  ami                    = var.image_id
  instance_type          = "t2.micro"
  subnet_id              = var.subnet_id
  key_name               = aws_key_pair.deployer.id
  vpc_security_group_ids = [aws_security_group.allow-all.id]
  tags = {
    Name = "${var.Project}-jenkins"
    env  = var.env
  }
}