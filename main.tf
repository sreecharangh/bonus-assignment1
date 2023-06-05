provider "aws" {
  region = "us-east-1"
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Path not found"
      status_code  = "404"
    }
  }
}

resource "aws_lb" "alb" {
  name               = "example-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["sg-08bc37cbeef00b2c1"]
  subnets            = ["subnet-09ac7b875f7eb94bf"]

  tags = {
    Name = "example-alb"
  }
}

locals {
  listener_rules = [
    { path = "/red", target_port = 8080 },
    { path = "/blue", target_port = 8081 },
    { path = "/green", target_port = 8082 },
  ]
}

resource "aws_lb_listener_rule" "listener_rule" {
  count          = length(local.listener_rules)
  listener_arn   = aws_lb_listener.listener.arn
  priority       = count.index + 1
  action {
    type            = "forward"
    target_group_arn = aws_lb_target_group.target_group[count.index].arn
  }
  condition {
    field  = "path-pattern"
    values = [local.listener_rules[count.index].path]
  }
}

resource "aws_lb_target_group" "target_group" {
  count     = length(local.listener_rules)
  name      = "example-target-group-${count.index}"
  port      = local.listener_rules[count.index].target_port
  protocol  = "HTTP"
  vpc_id    = "vpc-0700b3a5d0a8e01dd"

  health_check {
    path = "/"
  }
}

output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}
