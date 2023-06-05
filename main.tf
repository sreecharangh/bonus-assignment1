provider "aws" {
  region = "us-east-1"
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

resource "aws_lb_listener_rule" "listener_rule_red" {
  listener_arn = aws_lb_listener.listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group_red.arn
  }

  condition {
    field  = "path-pattern"
    values = ["/red"]
  }
}

resource "aws_lb_listener_rule" "listener_rule_blue" {
  listener_arn = aws_lb_listener.listener.arn
  priority     = 200

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group_blue.arn
  }

  condition {
    field  = "path-pattern"
    values = ["/blue"]
  }
}

resource "aws_lb_listener_rule" "listener_rule_green" {
  listener_arn = aws_lb_listener.listener.arn
  priority     = 300

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group_green.arn
  }

  condition {
    field  = "path-pattern"
    values = ["/green"]
  }
}

resource "aws_lb_target_group" "target_group_red" {
  name      = "example-target-group-red"
  port      = 8080
  protocol  = "HTTP"
  vpc_id    = "vpc-0700b3a5d0a8e01dd"

  health_check {
    path = "/"
  }
}

resource "aws_lb_target_group" "target_group_blue" {
  name      = "example-target-group-blue"
  port      = 8081
  protocol  = "HTTP"
  vpc_id    = "vpc-0700b3a5d0a8e01dd"

  health_check {
    path = "/"
  }
}

resource "aws_lb_target_group" "target_group_green" {
  name      = "example-target-group-green"
  port      = 8082
  protocol  = "HTTP"
  vpc_id    = "vpc-0700b3a5d0a8e01dd"

  health_check {
    path = "/"
  }
}

output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}
