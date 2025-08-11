# -------------------------
# Amazon Linux 2 AMI
# -------------------------
data "aws_ami" "amazon" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}
# ---------------------
# creating vpc
# ---------------------
resource "aws_vpc" "amar_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
}

# -----------------------------
# Public Subnet1
# -----------------------------
resource "aws_subnet" "public_subnet1" {
  vpc_id                  = aws_vpc.amar_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-southeast-1a"
  map_public_ip_on_launch = true
  tags ={
    name = "amar-pu"
  }
}

# ---------------------------------
# Public Subnet2
# ---------------------------------
resource "aws_subnet" "public_subnet2" {
  vpc_id            = aws_vpc.amar_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-southeast-1b"
  map_public_ip_on_launch = true
  tags = {
    name = "amar-priv"
  }
}
# ------------------------------
# internet gateway
# ------------------------------
resource "aws_internet_gateway" "amar-igw" {
  vpc_id = aws_vpc.amar_vpc.id

  tags = {
    Name = "igw"
  }
}

# ------------------------------
# creating security group
# ------------------------------
resource "aws_security_group" "amar_sg" {
  name        = "amar-sg"
  description = "Allow HTTP and SSH"
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
}

# -----------------------------------
# creating two Ec2 instances
# -----------------------------------
resource "aws_instance" "amar0324_1" {
  ami                         = data.aws_ami.amazonlinux.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_subnet1.id
  vpc_security_group_ids      = [aws_security_group.amar_sg.id]
  associate_public_ip_address = true   # ✅ Force public IP

  tags = {
    Name = "amar-public-ec2"
  }
}

resource "aws_instance" "amar0324_1-1" {
  ami                         = data.aws_ami.amazonlinux.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_subnet2.id
  vpc_security_group_ids      = [aws_security_group.amar_sg.id]
  associate_public_ip_address = true   # ✅ Force public IP

  tags = {
    Name = "amar-private-ec2"
  }
}

# ---------------------------------
# public route table
# ---------------------------------
resource "aws_route_table" "pu-routetable" {
  vpc_id = aws_vpc.amar_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.amar-igw.id
  }
  tags = {
    Name = "public_route"
  }
}
# ------------------------------
# route table association
# ------------------------------
resource "aws_route_table_association" "a"{
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.pu-routetable.id
}
resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.pu-routetable.id
}
# ---------------------------
# target group
# ---------------------------
resource "aws_lb_target_group" "amar-tg" {
  name     = "project-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.amar_vpc.id
}
# --------------------------
# Load Balancer
# --------------------------
resource "aws_lb" "amar_lb" {
  name               = "amar-lb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.amar_sg.id]
  subnets            = [for subnet in [aws_subnet.public_subnet1, aws_subnet.public_subnet2] : subnet.id]
}

# ----------------------
# create ami
# ----------------------
resource "aws_ami_from_instance" "amazonlinux" {
  name               = "pj-ami"
  source_instance_id = aws_instance.amar0324_1.id
  description        = "AMI created from my EC2 instance"
}

resource "aws_placement_group" "amar-auto" {
  name     = "amar-auto"
  strategy = "cluster"  # or "spread" / "partition" based on your needs
}
# ----------------------------------
# Launch instance from Ami
# ----------------------------------
# Launch instance from the fetched AMI
resource "aws_instance" "amar0324" {
  ami           = data.aws_ami.amazonlinux.id
  instance_type = "t2.micro"
}

# ----------------------------
# Launch Template
# ----------------------------
resource "aws_launch_template" "temp" {
  name_prefix   = "lt-from-instance-"
  image_id      = aws_ami_from_instance.amazonlinux.id
  instance_type = "t2.micro"  # Choose as required

  # Optional: Customize network interfaces
  network_interfaces {
    security_groups              = [aws_security_group.amar_sg.id]
    associate_public_ip_address  = true
    subnet_id                    = aws_subnet.public_subnet1.id
    device_index                 = 0
  }

  # Optional: Add tags to instances launched from this template
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "amar0324_1FromTemplate"
    }
  }
}


# --------------------------------
# Auto Scaling Group
# --------------------------------
resource "aws_autoscaling_group" "amar-auto" {
  name                      = "amarnath-autoscale"
  min_size                  = 1
  max_size                  = 3
  desired_capacity          = 2
   vpc_zone_identifier = [
    aws_subnet.public_subnet1.id,
    aws_subnet.public_subnet2.id
  ]

  launch_template {
    id      = aws_launch_template.temp.id
    version = "$Latest"
  }

  health_check_type         = "EC2"
  termination_policies      = ["OldestInstance"]
}





