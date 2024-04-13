
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.7.1" # Specify the version that suits your needs

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["eu-central-1a", "eu-central-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

module "ec2_instances" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.6.1" # Specify the version that suits your needs

  name     = "my-instance"
  for_each = toset(["master", "worker"])

  ami                    = "ami-0c55b159cbfafe1f0" # Replace this with a valid AMI for your region
  instance_type          = "t3.medium"
  key_name               = "aws-cks-machines"           # Ensure your key name matches the key created on AWS in EC2 service section
  subnet_id              = module.vpc.public_subnets[0] # Using the first public subnet
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = module.vpc.vpc_id

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
