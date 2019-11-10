resource "aws_security_group" "ecs-alb-sg" {
  vpc_id       = "${aws_vpc.VPC.id}"
  name         = "ecs-alb-sg"
  
 ingress {
    cidr_blocks = ["0.0.0.0/0" ] 
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }
  

  ingress {
    cidr_blocks = ["0.0.0.0/0"]  
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
  }
 egress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

   
 egress {
      from_port = 443
      to_port = 443
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  tags = {
    Name = "ecs-alb-sg"
  }

}

resource "aws_security_group" "ecs-instance-sg" {
  vpc_id       = "${aws_vpc.VPC.id}"
  name         = "ecs-instance-sg"
  
 ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = ["${aws_security_group.ecs-alb-sg.id}"]
  }
  
 egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
 }
 tags = {
    Name = "ecs-instance-sg"
  }
}