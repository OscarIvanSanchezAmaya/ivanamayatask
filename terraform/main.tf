
module "vpc" {
    subnets = var.subnets
}
resource "aws_ecs_cluster" "cluster" {
  name = "cluster"
}

module "roles" {
    count = lenght(var.roles)
    source = "./modules/roles.tf"
    role = ${lookup(var.roles[count.index], "role")}
    permisos = ${lookup(var.roles[count.index], "permisos")}
}

module "ecs" {
    count = length(var.apps)
    source = "./modules/ecs.tf"
    app = ${lookup(var.apps[count.index],"app")}
    typefile = ${lookup(var.apps[count.index],"typefile")}
    cluster = aws_ecs_cluster.cluster.id
    taskrole = module.roles[0].arn
    exrole = module.roles[1].arn

}