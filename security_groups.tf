# Security Group for ansible - using the rule for least privilege permission.
resource "aws_security_group" "ansible_sg" {
  name        = var.ansible_sg_name
  description = "Allow TLS inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH"
    from_port   = var.port_ssh
    to_port     = var.port_ssh
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr]
  }

  egress {
    from_port   = var.egress
    to_port     = var.egress
    protocol    = "-1"
    cidr_blocks = [var.all_cidr]
  }

  tags = {
    Name = var.ansible_sg_name
  }
}

# Security Group for the cluster - allowing all traffic to flow in and out. Server open up all ports 0 - 65535
resource "aws_security_group" "cluster_sg" {
  name        = var.cluster_sg_name
  description = "Allow TLS inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "TLS from VPC"
    from_port   = var.egress
    to_port     = var.cluster_port
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr]
  }

  egress {
    from_port   = var.egress
    to_port     = var.egress
    protocol    = "-1"
    cidr_blocks = [var.all_cidr]
  }

  tags = {
    Name = var.cluster_sg_name
  }
}

# create security group for Jenkins - using the rule for least privilege permission.
resource "aws_security_group" "jenkins_sg" {
  name        = var.jenkins_sg_name
  description = "Allow TLS inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH"
    from_port   = var.port_ssh
    to_port     = var.port_ssh
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr]
  }
  ingress {
    description = "Proxy Traffic"
    from_port   = var.port_jenkins
    to_port     = var.port_jenkins
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr]
  }
  ingress {
    description = "allow lb  access"
    from_port   = var.port_http
    to_port     = var.port_http
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr]
  }

  egress {
    from_port   = var.egress
    to_port     = var.egress
    protocol    = "-1"
    cidr_blocks = [var.all_cidr]
  }

  tags = {
    Name = var.jenkins_sg_name
  }
}