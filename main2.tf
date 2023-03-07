# Provider configuration
provider "aws" {
  region     = "us-east-1"
  access_key = "AKIA4ES2UAPGUXNZQUOY"
  secret_key = "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"
}



# Create a VPC
resource "aws_vpc" "terraform_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "terraform-vpc"
  }
}

# Create a subnet
resource "aws_subnet" "terrasubnet1" {
  vpc_id           = aws_vpc.terraform_vpc.id
  cidr_block       = "10.0.1.0/24"
  availability_zone = "us-east-1a"
   tags = {
    Name = "terraform_vpc"
  }
}

# Create a security group
resource "aws_security_group" "public_sg" {
  name_prefix = "public_sg_"
  vpc_id      = aws_vpc.terraform_vpc.id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create public EC2 instances
resource "aws_instance" "public" {
  count = 2

  ami           = "ami-0557a15b87f6559cf"
  instance_type = "t2.micro"

  key_name      = "mykey"
  associate_public_ip_address = true

  subnet_id     = aws_subnet.terrasubnet1.id

  tags = {
    Name = "public-instance-${count.index+1}"
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("mykey.pem")
    host        = self.public_ip
    timeout     = "15m" 
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install httpd -y",
      "sudo systemctl start httpd",
      "sudo systemctl enable httpd"
    ]
  }

  provisioner "local-exec" {
    command = "echo 'Public IP ${count.index + 1}: ${self.public_ip}' >> all-ips.txt"
  }
}
