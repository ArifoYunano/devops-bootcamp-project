data "aws_ami" "my_ami" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

# 1. Web Server (Public)
module "web_server" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 6.0"

  name                   = "devops-web-server"
  ami                    = data.aws_ami.my_ami.id
  instance_type          = "t3.small"
  subnet_id              = module.my_vpc.public_subnets[0]
  create_security_group  = false
  vpc_security_group_ids = [aws_security_group.devops_public_sg.id]
  private_ip             = "10.0.0.5"
  key_name               = "arifyunan-keypair"
  iam_instance_profile   = "EC2-SSM-Role"
  root_block_device      = { size = 16 }
  user_data_replace_on_change = true
  user_data = <<-EOF
    #cloud-config
    users:
      - name: ubuntu
        ssh_authorized_keys:
          - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILjygqKWGMFi6miCExPC24aw78IsVLGWi3GCkYsQjQ2X ssm-user@ip-10-0-0-135
  EOF

  tags = { Name = "devops-web-server" }
}

resource "aws_eip" "web_server_eip" {
  domain   = "vpc"
  instance = module.web_server.id

  tags = { Name = "devops-web-server-eip" }
}

# 2. Ansible Controller (Private)
module "ansible_controller" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 6.0"

  name                   = "devops-ansible-controller"
  ami                    = data.aws_ami.my_ami.id
  instance_type          = "t3.small"
  subnet_id              = module.my_vpc.private_subnets[0]
  create_security_group  = false
  vpc_security_group_ids = [aws_security_group.devops_private_sg.id]
  private_ip             = "10.0.0.135"
  key_name               = "arifyunan-keypair"
  iam_instance_profile   = "EC2-SSM-Role"
  root_block_device      = { size = 16 }

  tags = { Name = "devops-ansible-controller" }
}

# 3. Monitoring Server (Private)
module "monitoring_server" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 6.0"

  name                   = "devops-monitoring-server"
  ami                    = data.aws_ami.my_ami.id
  instance_type          = "t3.small"
  subnet_id              = module.my_vpc.private_subnets[0]
  create_security_group  = false
  vpc_security_group_ids = [aws_security_group.devops_private_sg.id]
  private_ip             = "10.0.0.136"
  key_name               = "arifyunan-keypair"
  iam_instance_profile   = "EC2-SSM-Role"
  root_block_device      = { size = 16 }
  user_data_replace_on_change = true
  user_data = <<-EOF
    #cloud-config
    users:
      - name: ubuntu
        ssh_authorized_keys:
          - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILjygqKWGMFi6miCExPC24aw78IsVLGWi3GCkYsQjQ2X ssm-user@ip-10-0-0-135
  EOF

  tags = { Name = "devops-monitoring-server" }
}