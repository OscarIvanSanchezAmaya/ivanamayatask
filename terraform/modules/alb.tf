data "aws_subnets" "public"{
  tags = {
    Type = "public"
  }
}
resource "aws_security_group" "alb_sg" {
  name        = "alb_sg"
  vpc_id      = var.vpc

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}


resource "aws_lb" "alb" {
  name               = "alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id] 
  subnets            = tolist(data.aws_subnets.public.ids)

  enable_deletion_protection = true
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.id

  default_action {
    target_group_arn = aws_lb_target_group.audio.id #por default deje audio
    type             = "forward"
  }
}



resource "aws_lb_target_group" "audio" {
  name        = "audio"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc
}
resource "aws_lb_target_group" "video" {
  name        = "video"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc
}
resource "aws_lb_target_group" "images" {
  name        = "images"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc
}

resource "aws_lb_listener_rule" "audio" {
  listener_arn = aws_lb_listener.listener.arn
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.audio.arn
  }

  condition {
    path_pattern {
      values = ["/audio"] #audio/video/images
    }
  }
}

resource "aws_lb_listener_rule" "video" {
  listener_arn = aws_lb_listener.listener.arn
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.video.arn
  }

  condition {
    path_pattern {
      values = ["/video"] #audio/video/images
    }
  }
}

resource "aws_lb_listener_rule" "images" {
  listener_arn = aws_lb_listener.listener.arn
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.images.arn
  }

  condition {
    path_pattern {
      values = ["/images"] #audio/video/images
    }
  }
}



output "target_audio" {
    value = aws_lb_target_group.audio.arn
}

output "target_video" {
    value = aws_lb_target_group.video.arn
}

output "target_images" {
    value = aws_lb_target_group.images.arn
}