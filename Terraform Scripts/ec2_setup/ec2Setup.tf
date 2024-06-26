provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "server" {
  ami                    = "ami-0440d3b780d96b29d"
  instance_type          = "t2.micro"
  key_name               = "loginKey"
  vpc_security_group_ids = [aws_security_group.servers-sg.id]
  subnet_id              = aws_subnet.server-vpc-subnet-01.id
  // with "for each" we can create multiple instances with single script, here we're creating 3 instances.
  for_each = toset(["Jenkins-master", "Build-slave", "Ansible-server"])
  tags = {
    Name = "${each.key}"
  }
}

resource "aws_security_group" "servers-sg" {
  name        = "servers-sg"
  description = "Allowing network traffic to instance"
  vpc_id      = aws_vpc.server-vpc.id
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

resource "aws_vpc" "server-vpc" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "server-VPC"
  }
}
resource "aws_subnet" "server-vpc-subnet-01" {
  vpc_id                  = aws_vpc.server-vpc.id
  cidr_block              = "10.1.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-east-1a"
  tags = {
    Name = "Server-subnet-01"
  }
}

resource "aws_subnet" "server-vpc-subnet-02" {
  vpc_id                  = aws_vpc.server-vpc.id
  cidr_block              = "10.1.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-east-1b"
  tags = {
    Name = "Server-subnet-02"
  }
}

resource "aws_internet_gateway" "server-vpc-ig" {
  vpc_id = aws_vpc.server-vpc.id
  tags = {
    Name = "server-vpc-IG"
  }
}

resource "aws_route_table" "server-RT" {
  vpc_id = aws_vpc.server-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.server-vpc-ig.id
  }
}

resource "aws_route_table_association" "server-rta-subnet-01" {
  subnet_id      = aws_subnet.server-vpc-subnet-01.id
  route_table_id = aws_route_table.server-RT.id
}
resource "aws_route_table_association" "server-rta-subnet-02" {
  subnet_id      = aws_subnet.server-vpc-subnet-02.id
  route_table_id = aws_route_table.server-RT.id
}

  module "sgs" {
    source = "../sg_eks"
    vpc_id     =     aws_vpc.loginKey-vpc.id
 }

  module "eks" {
       source = "../eks"
       vpc_id     =     aws_vpc.loginKey-vpc.id
       subnet_ids = [aws_subnet.loginKey-public-subnet-01.id,aws_subnet.loginKey-public-subnet-02.id]
       sg_ids = module.sgs.security_group_public
 }