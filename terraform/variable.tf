variable "subnets" {
    default = {
        subnet1 = {
            name = "private1"
            cidrblock = "10.0.0.0/24"
            az = "us-east-1a"
            type = "private"
        }
        subnet2 = {
            name = "private2"
            cidrblock = "10.0.1.0/24"
            az = "us-east-1b"
            type = "private"
        }
        subnet3 = {
            name = "public1"
            cidrblock = "10.0.2.0/24"
            az = "us-east-1a"
            type = "public"
        }
        subnet4 = {
            name = "public2"
            cidrblock = "10.0.3.0/24"
            az = "us-east-1b"
            type = "public"
        }
    }
}

variable "apps" {
    default = [
        {
            app = "audio"
            typefile = "mp3"
        },
        {
            app = "video"
            typefile = "mp4"
        },
        {
            app = "image"
            typefile = "jpg"
        }
    ]
}

variable "roles" {
    default = [
        {
            role = "taskrole"
            permisos = ["ecr:*"]
        },
        {
            role = "exrole"
            permisos = ["s3:*"]
        }
    ]
}