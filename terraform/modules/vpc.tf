#vpc
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "vpc"
  }
}
#subnets
resource "aws_subnet" "sub" {
  count = length(var.subnets)
  vpc_id     = aws_vpc.vpc.id
  availability_zone = "${lookup(var.subnets["subnet${count.index + 1}"], "az")}"
  cidr_block = "${lookup(var.subnets["subnet${count.index + 1}"], "cidrblock")}"
  map_public_ip_on_launch = "${lookup(var.subnets["subnet${count.index + 1}"], "type")} == public ? true : false"
  tags = {
    Name = "${lookup(var.subnets["subnet${count.index + 1}"], "name")}"
    Type = "${lookup(var.subnets["subnet${count.index + 1}"], "type")}"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id
}


resource "aws_route_table" "public" {
    vpc_id = aws_vpc.vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.gw.id
    }
}
#

###
data "aws_subnets" "private"{
  tags = {
    Type = "private"
  }
}
data "aws_subnets" "public"{
  tags = {
    Type = "public"
  }
}
resource "aws_eip" "eip" {
  for_each = toset(data.aws_subnets.private.ids)
  domain   = "vpc"
}
resource "aws_nat_gateway" "nat" {
  count = length(data.aws_subnets.public.ids)
  allocation_id = aws_eip.eip[count.index].id
  subnet_id  = tolist(data.aws_subnets.public.ids)[count.index]
}
###
resource "aws_route_table" "priv" {
    count = length(data.aws_subnets.private.ids)
    vpc_id = aws_vpc.vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat[count.index].id
    }
}



resource "aws_route_table_association" "public" {
  count = length(aws_subnet.sub[*].id)
  subnet_id      = aws_subnet[count.index].id
  route_table_id = "${lookup(var.subnets["subnet${count.index + 1}"], "type")} == public ? ${aws_route_table.public.id} : ${aws_route_table.priv.id} "
}
#

output "vpc" {
    value = aws_vpc.vpc.id
}