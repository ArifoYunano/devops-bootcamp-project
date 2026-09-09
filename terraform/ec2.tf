data "aws_ami" "my_ami" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

data "aws_iam_instance_profile" "my_ssm_profile" {
  name = "EC2-SSM-Role"
}

data "aws_ssm_parameter" "token" {
  name = "/devops-bootcamp-2026/tunnel-token"
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
  vpc_security_group_ids = [module.devops_public_sg.id]
  private_ip             = "10.0.0.5"
  key_name               = "arifyunan-keypair"
  iam_instance_profile   = data.aws_iam_instance_profile.my_ssm_profile.name
  root_block_device      = { size = 16 }
  tags                   = { Name = "devops-web-server" }
}

# 2. Elastic IP association 
resource "aws_eip_association" "web_server_eip" {
  instance_id   = module.web_server.id
  allocation_id = "eipalloc-0faeffe3858272e98"
}

# 3. Ansible Controller (Private)
module "ansible_controller" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 6.0"

  name                   = "devops-ansible-controller"
  ami                    = data.aws_ami.my_ami.id
  instance_type          = "t3.small"
  subnet_id              = module.my_vpc.private_subnets[0]
  create_security_group  = false
  vpc_security_group_ids = [module.devops_private_sg.id]
  private_ip             = "10.0.0.135"
  key_name               = "arifyunan-keypair"
  iam_instance_profile   = data.aws_iam_instance_profile.my_ssm_profile.name
  root_block_device      = { size = 16 }
  tags                   = { Name = "devops-ansible-controller" }

}

# 4. Monitoring Server (Private)
module "monitoring_server" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 6.0"

  name                        = "devops-monitoring-server"
  ami                         = data.aws_ami.my_ami.id
  instance_type               = "t3.small"
  subnet_id                   = module.my_vpc.private_subnets[0]
  create_security_group       = false
  vpc_security_group_ids      = [module.devops_private_sg.id]
  private_ip                  = "10.0.0.136"
  key_name                    = "arifyunan-keypair"
  iam_instance_profile        = data.aws_iam_instance_profile.my_ssm_profile.name
  root_block_device           = { size = 16 }
  user_data_replace_on_change = true
  tags                        = { Name = "devops-monitoring-server" }

}