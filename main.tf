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
  default_tags {
    tags = {
      Project     = "${var.Project}"
      Environment = "${var.env}"
    }
  }
}
## Key Pair creation
resource "aws_key_pair" "deployer" {
  key_name   = "${var.Project}-key"
  public_key = file("./new-key.pub")
}

## Security Group Creation
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

##Enable security inbound rule using for loop
##resource "aws_security_group_rule" "inbound_main" {
##  for_each = toset(var.open-ports)
##  type = "ingress"
## security_group_id = aws_security_group.allow-all.id
##  from_port = each.key
##  to_port = each.key
##  protocol = "tcp"
##  cidr_blocks = ["0.0.0.0/0"]
#}
resource "aws_security_group_rule" "outbound" {
  type              = "egress"
  from_port         = "0"
  to_port           = "0"
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.allow-all.id
}

##EC2 instance creation
resource "aws_instance" "Jenkins-vm" {
  ami                    = var.image_id
  instance_type          = "t2.micro"
  subnet_id              = var.subnet_id
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.allow-all.id]
  tags = {
    Name = "${var.Project}-jenkins"
  }
}


##Elastic IP creation and assoiation
resource "aws_eip" "Jenkins-eip" {
  count    = var.aws_static_ip == true ? 1 : 0 ##here condition checks if variable value equals to true create and attach it to instance 
  instance = aws_instance.Jenkins-vm.id
  domain   = "vpc"
  tags = {
    Name = "${var.Project}-jenkins-eip"
  }
}