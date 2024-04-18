
resource "aws_ecs_task_definition" "service" {
    network_mode = "awsvpc"
    requires_compatibilities = ["FARGATE"]
    family = "${var.app}" 
    cpu = .25 vcPU
    memory = 0.5 GB
    task_role_arn = var.taskrole 
    execution_role_arn = var.exrole
    container_definitions    = <<TASK_DEFINITION
[
  {
    "name": "${var.app}-container",
    "image": "public.ecr.aws/ecs-sample-image/amazon-ecs-sample:latest",
    "essential": true
    "environment":[{"name":"typefile", "value":"${var.typefile}"}]

    "portMappings" = [
        containerPort = 80
        hostPort = 80
    ]

  }
]
TASK_DEFINITION
}
data "aws_subnets" "private"{
  tags = {
    Type = "private"
  }
}
resource "aws_ecs_service" "mongo" {
    name = "${var.app}-service"
    cluster = var.cluster
    task_definition = aws_ecs_task_definition.service.arn
    launch_type = FARGATE
    desired_count = 1
    network_configuration {
        subnets = tolist(data.aws_subnets.private.ids) 
    }
    load_balancer = {
        target_group_arn = 
        container_name   = "${var.app}-container"
        container_port   = 80
    }

}