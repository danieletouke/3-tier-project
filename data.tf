data "aws_ami" "latest-ami2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
data "aws_vpc" "default_vpc" {
  default = true
}
data "aws_subnet_ids" "default_subnet" {
  vpc_id = data.aws_vpc.default_vpc.id
}
data "aws_route53_zone" "mydomain" {
    name = "deliveredme.click"
}

