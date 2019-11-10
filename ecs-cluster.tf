resource "aws_ecs_cluster" "ecs-cluster-web-app" {
  name = "ecs-cluster-Fizz-Buzz"
}

data "template_file" "container-definition" {
  template = <<EOF
[
  {
    "name": "fizzbuzz",
    "image": "milanthanuja/fizzbuzz:1",
    "cpu": 0,
    "memory": 128,
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80
      }
    ]
  }
]
EOF
}
resource "aws_ecs_task_definition" "service" {
  family                = "service"
  container_definitions = "${data.template_file.container-definition.rendered}"
  network_mode = "host"
  execution_role_arn = "${aws_iam_role.ecs-service-role.arn}"

}

resource "aws_ecs_service" "ecs-service" {
  name            = "Fizz-Buzz"
  cluster         = "${aws_ecs_cluster.ecs-cluster-web-app.id}"
  task_definition = "${aws_ecs_task_definition.service.arn}"
  desired_count   = 2
  deployment_maximum_percent = 200
  deployment_minimum_healthy_percent = 100
}



