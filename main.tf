# Provider configuration
provider "aws" {
  region     = "us-east-1"
  access_key = "AKIA4ES2UAPGTF7ZRZNS"
  secret_key = "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"
}

# Create VPC
resource "aws_vpc" "terraform-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "terraform-vpc"
  }
}

# Create public subnet
resource "aws_subnet" "terrasubnet1" {
  vpc_id     = aws_vpc.terraform-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "terrasubnet1"
  }
}

# Create private subnet
resource "aws_subnet" "terrasubnet2" {
  vpc_id     = aws_vpc.terraform-vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "terrasubnet2"
  }
}

# Create security group for public instances
resource "aws_security_group" "public_sg" {
  name_prefix = "public-sg"
  vpc_id      = aws_vpc.terraform-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
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

# Create security group for private instances
resource "aws_security_group" "private_sg" {
  name_prefix = "private-sg"
  vpc_id      = aws_vpc.terraform-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.2.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create public EC2 instances
resource "aws_instance" "public" {
  count = 2

  ami           = "ami-0557a15b87f6559cf"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.terrasubnet1.id
  key_name      = "mykey"

  security_groups = [
    aws_security_group.public_sg.id
  ]

  tags = {
    Name = "Public Instance ${count.index + 1}"
  }
}

# Create private EC2 instances
resource "aws_instance" "private" {
  count = 2

  ami           = "ami-0557a15b87f6559cf"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.terrasubnet2.id
  key_name      = "mykey"

  security_groups = [
    aws_security_group.private_sg.id
  ]
}