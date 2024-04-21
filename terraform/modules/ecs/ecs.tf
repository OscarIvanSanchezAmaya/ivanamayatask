
resource "aws_ecs_task_definition" "task" {
    network_mode = "awsvpc"
    requires_compatibilities = ["FARGATE"]
    family = "${var.app}" 
    cpu = ".25 vcPU"
    memory = "0.5 GB"
    task_role_arn = var.taskrole 
    execution_role_arn = var.exrole
    container_definitions    = <<TASK_DEFINITION
[
  {
    "name": "container",
    "image": "public.ecr.aws/ecs-sample-image/amazon-ecs-sample:latest",
    "essential": true
    "environment":[{"name":"typefile", "value":"${var.typefile}"},{"name":"bucket", "value":"${var.bucket}"}]

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
resource "aws_ecs_service" "service" {
    name = "${var.app}-service"
    cluster = var.cluster
    task_definition = aws_ecs_task_definition.task.arn
    launch_type = FARGATE
    desired_count = 1
    network_configuration {
        subnets = tolist(data.aws_subnets.private.ids) 
    }
    load_balancer = {
        target_group_arn = var.target
        container_name   = "container"
        container_port   = 80
    }

}

output "service" {
    value = aws_ecs_service.service.name
}
