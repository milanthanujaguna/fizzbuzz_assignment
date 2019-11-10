resource "aws_lb" "alb" {
  name               = "ecs-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.ecs-alb-sg.id}"]
  subnets            = ["${aws_subnet.VPC-az1-subnets.*.id[1]}","${aws_subnet.VPC-az2-subnets.*.id[1]}"]

  enable_deletion_protection = false

  
  tags = {
      Name = "ecs-alb"
  }
}


resource "aws_alb_target_group" "ecs-target-group" {
  name     = "ecs-target-group"
  port     = 80
  protocol = "HTTP"
  target_type = "instance"
  vpc_id   = "${aws_vpc.VPC.id}"
  health_check {
                path = "/"
                port = "80"
                protocol = "HTTP"
                healthy_threshold = 3
                unhealthy_threshold = 3
                interval = 300
                timeout = 120
                matcher = "200-308"
        }
}

resource "aws_lb_listener" "ecs-alb-http-listner" {
  load_balancer_arn = "${aws_lb.alb.arn}"
  port              = "80"
  protocol          = "HTTP"
  

  default_action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.ecs-target-group.arn}"
  }
}

