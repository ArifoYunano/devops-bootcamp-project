# 1. Public Security Group
resource "aws_security_group" "devops_public_sg" {
  name        = "devops-public-sg"
  description = "Security group for public resources"
  vpc_id      = module.my_vpc.vpc_id

  ingress {
    description = "Allow HTTP traffic from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow Node Exporter / Prometheus monitoring"
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.136/32"]
  }

  ingress {
    description = "Allow SSH from within VPC subnet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [module.my_vpc.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "devops-public-sg"
  }
}

# 2. Private Security Group
resource "aws_security_group" "devops_private_sg" {
  name        = "devops-private-sg"
  description = "Security group for private resources"
  vpc_id      = module.my_vpc.vpc_id

  ingress {
    description = "Allow SSH from within VPC subnet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [module.my_vpc.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "devops-private-sg"
  }
}