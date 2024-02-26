provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "server" {
  ami                    = "ami-0440d3b780d96b29d"
  instance_type          = "t2.micro"
  key_name               = "loginKey"
  vpc_security_group_ids = ["servers-sg"]
  tags = {
    Name = "Server"
  }
}

resource "aws_security_group" "severs-sg" {
  name        = "servers-sg"
  description = "Allowing network traffic to instance"
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
  tags = {
    Name = "Server-SecurityGroup"
  }
}

output "public_ip" {
  value = aws_instance.server.public_ip
}