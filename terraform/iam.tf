# Rol de seguridad para que futuras funciones Lambda puedan ejecutarse
resource "aws_iam_role" "lambda_role" {
  name = "lambda-ejecucion-rol-${terraform.workspace}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Environment = terraform.workspace
  }
}