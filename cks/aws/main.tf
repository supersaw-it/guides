module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.7.1"

  name = "cks-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["eu-central-1a", "eu-central-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  default_security_group_ingress = [
    {
      from_port   = 0,
      to_port     = 0,
      protocol    = "-1",
      cidr_blocks = ["10.0.0.0/16"],
      description = "Allow all inbound traffic from within the VPC"
    }
  ]

  default_security_group_egress = [
    {
      from_port   = 0,
      to_port     = 0,
      protocol    = "-1",
      cidr_blocks = ["0.0.0.0/0"],
      description = "Allow all outbound traffic"
    }
  ]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }

  default_security_group_name = "cks-default-vpc-sg"
  default_security_group_tags = {
    Name = "cks-default-vpc-sg"
  }
}

module "ec2_instances" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.6.1" # Specify the version that suits your needs

  for_each = toset(["master", "worker"])
  name     = "cks-${each.key}"

  ami                    = var.ami_id # Replace this with a valid AMI for your region
  instance_type          = "t3.medium"
  key_name               = "cks-machines"               # The key created on AWS in EC2 service section; chmod 400 ~/.ssh/<KEY>.pem
  subnet_id              = module.vpc.public_subnets[0] # Using the first public subnet
  vpc_security_group_ids = [aws_security_group.allow_ssh_and_ports.id]

  associate_public_ip_address = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_security_group" "allow_ssh_and_ports" {
  name        = "allow_ssh_and_ports"
  description = "Allow SSH and specific port range inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # K8s ingress rule for ports 30000-40000
  ingress {
    from_port   = 30000
    to_port     = 40000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow outbound traffic for all ports
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh_and_ports"
  }
}
