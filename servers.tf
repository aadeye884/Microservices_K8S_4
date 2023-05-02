resource "aws_instance" "Master_nodes" {
  count                  = var.master_node_count #the total number of instances we want 
  ami                    = var.ubuntu_ami
  instance_type          = var.instance_type_medium
  vpc_security_group_ids = [aws_security_group.cluster_sg.id]
  subnet_id              = element(module.vpc.private_subnets, count.index) # the element function helps us fetch all the private subnets we have provisioned in our VPC using the count.index
  key_name               = aws_key_pair.us_keypair.key_name

  tags = {
    Name = format("Master-%02d", count.index + 1)
  }
}

resource "aws_instance" "Worker_nodes" {
  count                  = var.worker_node_count
  ami                    = var.ubuntu_ami
  instance_type          = var.instance_type_medium
  vpc_security_group_ids = [aws_security_group.cluster_sg.id]
  subnet_id              = element(module.vpc.private_subnets, count.index)
  key_name               = aws_key_pair.us_keypair.key_name

  tags = {
    Name = format("Worker-%02d", count.index + 1)
  }
}

# create bastions_host
resource "aws_instance" "bastion_ansible_server" {
  ami                         = var.ubuntu_ami
  instance_type               = var.instance_type_micro
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.ansible_sg.id]
  key_name                    = aws_key_pair.us_keypair.key_name
  user_data                   = <<-EOF
#!/bin/bash
echo "PubkeyAcceptedkeyTypes=+ssh-rsa" >> /etc/ssh/sshd_config.d/10-insecure-rsa-keysig.conf
systemctl reload sshd
echo "${tls_private_key.us_teamkeypair.private_key_pem}" >> /home/ubuntu/.ssh/id_rsa
chown ubuntu /home/ubuntu/.ssh/id_rsa
chgrp ubuntu /home/ubuntu/.ssh/id_rsa
chmod 600 /home/ubuntu/.ssh/id_rsa
echo "starting anible install"
apt-add-repository ppa:ansible/ansible -y
apt update
apt install ansible -y
EOF
  tags = {
    Name = var.usteam_bastion_ansible_name
  }
}

# Create Jenkins Server
resource "aws_instance" "jenkins_server" {
  ami                    = var.redhat_ami_id
  instance_type          = var.instance_type_medium2
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  subnet_id              = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  key_name               = aws_key_pair.us_keypair.key_name
  user_data              = <<-EOF
#!/bin/bash
sudo yum update -y
sudo yum install wget -y
sudo yum install git -y
sudo wget https://get.jenkins.io/redhat/jenkins-2.346-1.1.noarch.rpm
sudo rpm -ivh jenkins-2.346-1.1.noarch.rpm
sudo yum install java-11-openjdk -y
sudo systemctl daemon-reload
sudo systemctl start jenkins
sudo systemctl enable jenkins
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install docker-ce -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user
sudo usermod -aG docker jenkins
sudo hostnamectl set-hostname Jenkins
EOF
  tags = {
    Name = var.jenkins_server_name
  }
}
