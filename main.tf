# creating 2 ec2 and use python to start a http server on port 8080
resource "aws_instance" "instance_1" {
  ami             = data.aws_ami.ubuntu.id # Ubuntu 20.04 LTS // us-east-1
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.instances.name]
  user_data       = <<-EOF
              #!/bin/bash
              echo "Hello, World 1" > index.html
              python3 -m http.server 8080 &
              EOF
}
resource "aws_instance" "instance_2" {
  ami             = data.aws_ami.ubuntu.id # Ubuntu 20.04 LTS // us-east-1
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.instances.name]
  user_data       = <<-EOF
              #!/bin/bash
              echo "Hello, World 2" > index.html
              python3 -m http.server 8080 &
              EOF
}

#  creating a security group for my server
resource "aws_security_group" "instances" {
  name = "insatnce-security-group"
}
# creating rules for my server security group
resource "aws_security_group_rule" "allow_http_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.instances.id
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}
#  create a load balancer
/* resource "aws_alb" "load_blancer" {
  name               = "web-app-lb"
  load_balancer_type = "application"
  subnets            = data.aws_subnet_ids.default_subnet.ids
  security_groups    = [aws_security_group.alb.id]
} */
/* output "aws" {
  value = data.aws_subnet_ids.default_subnet.ids
} */

# creating an s3 bucket
resource "aws_s3_bucket" "bucket" {
  bucket        = "codixtech-directive-web-app-data-1984"
  force_destroy = true
}
resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_crypto_conf" {
  bucket = aws_s3_bucket.bucket.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

/* data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["self"] # Canonical
}
data "aws_vpc" "default_vpc" {
  default = true
}
data "aws_subnet_ids" "default_subnet" {
  vpc_id = data.aws_vpc.default_vpc.id
}


# create the listener
resource "aws_lb_listener" "instances" {
  load_balancer_arn = aws_alb.load_blancer.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}
#  create a target group
resource "aws_lb_target_group" "ip-example" {
  name     = "example-target-group"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default_vpc.id
  health_check {
    path               = "/"
    protocol           = "HTTP"
    matcher            = "200"
    interval           = 15
    timeout            = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}
# attaching ec2_1 to the target group
resource "aws_lb_target_group_attachment" "instance_1" {
  target_group_arn = aws_lb_target_group.ip-example.arn
  target_id        = aws_instance.instance_1.id
  port             = 8080
}
# attaching ec2_2 to the target group
resource "aws_lb_target_group_attachment" "instance_2" {
  target_group_arn = aws_lb_target_group.ip-example.arn
  target_id        = aws_instance.instance_2.id
  port             = 8080
}
# Fixed-response action
resource "aws_lb_listener_rule" "instances" {
  listener_arn = aws_lb_listener.instances.arn
  priority     = 100
  condition {
    path_pattern {
      values = ["*"]
    }
  }
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ip-example.arn
  }
}
# load balancer security group
resource "aws_security_group" "alb" {
  name = "alb-security-group"
}
# specified traffic that for the load balancer
resource "aws_security_group_rule" "allow_alb_http_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.alb.id
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "allow_alb_all_outbound" {
  type              = "egress"
  security_group_id = aws_security_group.alb.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}
data "aws_route53_zone" "mydomain" {
    name = "deliveredme.click"
}
resource "aws_route53_record" "test2" {
  zone_id = data.aws_route53_zone.mydomain.id
  name    = "test"
  type    = "A"
  alias {
    name                   =  aws_alb.load_blancer.dns_name
    zone_id                = aws_alb.load_blancer.zone_id
    evaluate_target_health = true
  }
} */