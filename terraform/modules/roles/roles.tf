resource "aws_iam_role" "test_role" {
  name = "${var.role}-ecs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["sts:AssumeRole"]
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = var.service
        }
      },
    ]
  })
  inline_policy {
    name = "${var.role}-policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = var.permisos
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }

}

output "arn" {
    value = aws_iam_role.test_role.arn
}