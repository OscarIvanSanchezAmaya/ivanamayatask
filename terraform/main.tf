resource "aws_s3_bucket" "bucket" {
  bucket = "ivan-task"
  }

  resource "aws_s3_bucket" "ci-bucket" {
  bucket = "ci-ivan-task"
  }

  data "archive_file" "init" {
    type = "zip"
    source_dir = "./app"
    output_path = "./app.zip"
  }
  resource "aws_s3_bucket_object" "app"{
    bucket = aws_s3_bucket.ci-bucket.id
    key = "app.zip"
    source = "./app.zip"
  }


module "vpc" {
    source = "./modules/vpc"
    subnets = var.subnets
}
resource "aws_ecs_cluster" "cluster" {
  name = "cluster"
}

module "roles" {
    count = lenght(var.roles)
    source = "./modules/roles"
    role = "${lookup(var.roles[count.index], "role")}"
    permisos = "${lookup(var.roles[count.index], "permisos")}"
    service = "${lookup(var.roles[count.index], "service")}"
}
module "alb" {
    source = "./modules/alb"
    vpc = module.vpc.vpc
}
locals {
    target = [module.alb.target_audio, module.alb.target_video, module.alb.target_iamges]
}
module "ecs" {
    count = length(var.apps)
    source = "./modules/ecs"
    app = "${lookup(var.apps[count.index],"app")}"
    typefile = "${lookup(var.apps[count.index],"typefile")}"
    bucket = aws_s3_bucket.bucket.id
    cluster = aws_ecs_cluster.cluster.id
    taskrole = module.roles[0].arn
    exrole = module.roles[1].arn
    target = locals.target[count.index]
}

module "ci"{
    source = "./modules/ci"
    cluster = aws_ecs_cluster.cluster.id
    ServiceNameAudio = module.ecs[0].service
    ServiceNameVideo = module.ecs[1].service
    ServiceNameImages = module.ecs[2].service
    bucket = aws_s3_bucket.ci-bucket.id
    role = module.role[2].arn


}

