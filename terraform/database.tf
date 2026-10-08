# Tabla de DynamoDB modo On-Demand 
resource "aws_dynamodb_table" "tabla_principal" {
  name         = "tabla-proyectos-${terraform.workspace}"
  billing_mode = "PAY_PER_REQUEST" 
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name        = "Base de Datos ${terraform.workspace}"
    Environment = terraform.workspace
  }
}