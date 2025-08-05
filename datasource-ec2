# Datasource
data "aws_ami" "amazonlinux" {
  most_recent = true

  owners = ["137112412989"] # Canonical

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
