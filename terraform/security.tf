data "http" "myip" {
  url = "https://ifconfig.me/ip"
}

# 1. Public Security Group - Web Server
module "devops_public_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 6.0"

  name            = "devops-public-sg"
  use_name_prefix = false
  vpc_id          = module.my_vpc.vpc_id

  ingress_rules = {
    # Public HTTP access to the web server
    http = {
      cidr_ipv4   = "0.0.0.0/0"
      ip_protocol = "tcp"
      from_port   = 80
      to_port     = 80
    }

    # SSH from within your VPC only
    ssh = {
      cidr_ipv4   = module.my_vpc.vpc_cidr_block
      ip_protocol = "tcp"
      from_port   = 22
      to_port     = 22
    }

    # Node Exporter on web server, monitored only by monitoring server
    node_exporter = {
      cidr_ipv4   = "10.0.0.136/32"
      ip_protocol = "tcp"
      from_port   = 9100
      to_port     = 9100
    }
  }

  egress_rules = {
    all = {
      cidr_ipv4   = "0.0.0.0/0"
      ip_protocol = "-1"
    }
  }

  tags = {
    Name = "devops-public-sg"
  }
}

# 2. Private Security Group - Ansible Controller and Monitoring Server
module "devops_private_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 6.0"

  name            = "devops-private-sg"
  use_name_prefix = false
  vpc_id          = module.my_vpc.vpc_id

  ingress_rules = {
    # SSH between instances inside this VPC
    ssh = {
      cidr_ipv4   = "10.0.0.0/24"
      ip_protocol = "tcp"
      from_port   = 22
      to_port     = 22
    }

    # Prometheus web UI: only your current public IP can access it
    prometheus = {
      cidr_ipv4   = "${chomp(data.http.myip.response_body)}/32"
      ip_protocol = "tcp"
      from_port   = 9090
      to_port     = 9090
    }

    # Node Exporter, if you need it on private instances
    node_exporter = {
      cidr_ipv4   = "10.0.0.136/32"
      ip_protocol = "tcp"
      from_port   = 9100
      to_port     = 9100
    }

    # Grafana web UI: only your current public IP can access it
    grafana = {
      cidr_ipv4   = "${chomp(data.http.myip.response_body)}/32"
      ip_protocol = "tcp"
      from_port   = 3000
      to_port     = 3000
    }
  }

  egress_rules = {
    all = {
      cidr_ipv4   = "0.0.0.0/0"
      ip_protocol = "-1"
    }
  }

  tags = {
    Name = "devops-private-sg"
  }
}