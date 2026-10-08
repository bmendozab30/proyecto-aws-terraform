resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "vpc-${terraform.workspace}" }
}

# Subredes Privadas para las Lambdas
resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
  tags              = { Name = "priv-a-${terraform.workspace}" }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.12.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]
  tags              = { Name = "priv-b-${terraform.workspace}" }
}

# Tabla de ruteo privada sin NAT Gateway
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "rt-private-${terraform.workspace}" }
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private.id
}

# VPC Endpoints para comunicación interna con S3 y SQS
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.us-east-1.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private.id]
  tags              = { Name = "vpce-s3-${terraform.workspace}" }
}

resource "aws_security_group" "vpce_sqs_sg" {
  name        = "secgroup-vpce-sqs-${terraform.workspace}"
  description = "Permite acceso HTTPS a SQS dentro de la VPC"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }
}

resource "aws_vpc_endpoint" "sqs" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.us-east-1.sqs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_a.id, aws_subnet.private_b.id]
  security_group_ids  = [aws_security_group.vpce_sqs_sg.id]
  private_dns_enabled = true
  tags                = { Name = "vpce-sqs-${terraform.workspace}" }
}