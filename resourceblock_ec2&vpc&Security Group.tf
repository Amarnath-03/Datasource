# Creating Vpc
# ------------------------------
resource "aws_vpc" "amar_vpc" {
  cidr_block = "110.0.0.0/16"
  tags = {
    Name = "vcube"
  }
}

# -------------------------
# Subnet
# -------------------------
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.amar_vpc.id
  cidr_block        = "110.0.1.0/24"
  availability_zone = "ap-southeast-1a"
  tags = {
    Name = "public"
  }
}

# -------------------------
# Internet Gateway
# -------------------------
resource "aws_internet_gateway" "amar_igw" {
  vpc_id = aws_vpc.amar_vpc.id
  tags = {
    Name = "vcube-igw"
  }
}

# -------------------------
# Route Table
# -------------------------
resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.amar_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.amar_igw.id
  }

  tags = {
    Name = "pub-route"
  }
}

# -------------------------
# Route Table Association
# -------------------------
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route.id
}

# -------------------------
# Security Group - Allow SSH and HTTP
# -------------------------
resource "aws_security_group" "amar_sg" {
  name        = "allow-ssh-http"
  description = "Allow SSH and HTTP access"
  vpc_id      = aws_vpc.amar_vpc.id

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

  tags = {
    Name = "allow-ssh-http"
  }
}

# -------------------------------
# Creating Ec2 Instance
# -------------------------------
resource "aws_instance" "amar0324" {
  ami                         = data.aws_ami.amazonlinux.id
  instance_type               = var.ec2_instance_type
  subnet_id                   = aws_subnet.public_subnet.id
  key_name                    = "ppa"
  user_data                   = file("nginxinstall.sh")
  vpc_security_group_ids      = [aws_security_group.amar_sg.id]

  associate_public_ip_address = true

  tags = {
    Name = "vcube138"
  }
}

