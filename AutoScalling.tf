resource "aws_autoscaling_group" "autoscaling-group" {
  name                      = "ecs-autoscaling"
  max_size                  = 2
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 2
  force_delete              = true
  target_group_arns         = ["${aws_alb_target_group.ecs-target-group.arn}"]
  vpc_zone_identifier       = ["${aws_subnet.VPC-az1-subnets.*.id[0]}", "${aws_subnet.VPC-az2-subnets.*.id[0]}"]
  launch_template {
    id      = "${aws_launch_template.ecs-instance-temp.id}"
    version = "$Latest"
  }
  
}

data "template_file" "user_data" {
  template = <<EOF
#!/bin/bash
yum update -y
echo ECS_CLUSTER=${aws_ecs_cluster.ecs-cluster-web-app.name} >> /etc/ecs/ecs.config

EOF
}

resource "aws_launch_template" "ecs-instance-temp" {
    name = "ECS-Instace-temp"
    image_id = "ami-089e8db6cdcb5c702"
    instance_type = "t2.nano"
    vpc_security_group_ids = ["${aws_security_group.ecs-instance-sg.id}"]
    iam_instance_profile  {
      
      name = "${aws_iam_instance_profile.ecs-instance-profile.id}"
    
    }
    monitoring {
    enabled = true
  }
  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = 30
      encrypted = true
      volume_type = "gp2"
    }
  }
  user_data = "${base64encode(data.template_file.user_data.rendered)}"
}

