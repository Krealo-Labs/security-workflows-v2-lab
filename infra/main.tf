# =============================================================================
# FIXTURES VULNERABLES DELIBERADOS - NO USAR COMO REFERENCIA
#
# Cada recurso de este archivo contiene una mala configuracion intencional
# para verificar que Trivy (scan-type: config) la detecta.
# Este codigo NUNCA debe desplegarse.
# =============================================================================

provider "aws" {
  region = "us-east-1"
}

# FIXTURE 1 - Bucket S3 sin cifrado en reposo
resource "aws_s3_bucket" "sin_cifrado" {
  bucket = "lab-fixture-bucket-sin-cifrado"
}

# FIXTURE 2 - Security group con SSH abierto a todo internet
resource "aws_security_group" "ssh_abierto" {
  name        = "lab-fixture-ssh-abierto"
  description = "Fixture: SSH expuesto a 0.0.0.0/0"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# FIXTURE 3 - RDS publicamente accesible y sin cifrado
resource "aws_db_instance" "rds_expuesta" {
  identifier          = "lab-fixture-rds"
  engine              = "postgres"
  instance_class      = "db.t3.micro"
  allocated_storage   = 20
  username            = "admin"
  password            = "Password123"
  publicly_accessible = true
  storage_encrypted   = false
  skip_final_snapshot = true
}

# FIXTURE 4 - Politica IAM con privilegios totales
resource "aws_iam_policy" "privilegios_totales" {
  name = "lab-fixture-admin-total"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "*"
        Resource = "*"
      }
    ]
  })
}

# FIXTURE 5 - Volumen EBS sin cifrado
resource "aws_ebs_volume" "ebs_sin_cifrado" {
  availability_zone = "us-east-1a"
  size              = 10
  encrypted         = false
}

# FIXTURE 6 - Bucket S3 con ACL publica y sin bloqueo de acceso publico
resource "aws_s3_bucket" "bucket_publico" {
  bucket = "lab-fixture-bucket-publico"
}

resource "aws_s3_bucket_acl" "acl_publica" {
  bucket = aws_s3_bucket.bucket_publico.id
  acl    = "public-read"
}

# FIXTURE 7 - Load balancer con listener HTTP en lugar de HTTPS
resource "aws_lb" "alb_sin_tls" {
  name               = "lab-fixture-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = ["subnet-00000000", "subnet-11111111"]
}

resource "aws_lb_listener" "listener_http" {
  load_balancer_arn = aws_lb.alb_sin_tls.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "ok"
      status_code  = "200"
    }
  }
}
