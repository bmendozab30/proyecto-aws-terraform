# 1. Bucket S3 para almacenamiento de archivos
resource "aws_s3_bucket" "archivos" {
  bucket = "proyecto-aws-bucket-mendoza-${terraform.workspace}"
  
  tags = {
    Name        = "Bucket Proyecto ${terraform.workspace}"
    Environment = terraform.workspace
  }
}

# 2. Cola SQS para procesamiento de mensajes asíncronos
resource "aws_sqs_queue" "mensajes" {
  name                      = "cola-mensajes-${terraform.workspace}"
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 86400 # Retención de 1 día para desarrollo
  
  tags = {
    Name        = "Cola SQS ${terraform.workspace}"
    Environment = terraform.workspace
  }
}