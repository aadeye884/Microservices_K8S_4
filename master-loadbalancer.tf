# load balancer node provisioning
#Create load balancer node
resource "aws_instance" "lb_node" {
  ami                         = var.ubuntu_ami
  instance_type               = var.instance_type_micro
  subnet_id                   = module.vpc.public_subnets[1]
  vpc_security_group_ids      = [aws_security_group.cluster_sg.id]
  key_name                    = aws_key_pair.us_keypair.id
  associate_public_ip_address = true
  user_data                   = <<-EOF
#!/bin/bash
sudo -i
apt-get update -y
apt-get upgrade -y  

#Install software-properties-common
apt install --no-install-recommends software-properties-common

# Add vbernat/haproxy-2.4 to system's package manager 
add-apt-repository ppa:vbernat/haproxy-2.4 -y 

# Install Haproxy
apt install haproxy=2.4.\* -y  

cat <<EOT>> /etc/haproxy/haproxy.cfg
frontend fe-apiserver
   bind 0.0.0.0:6443
   mode tcp
   option tcplog
   default_backend be-apiserver
backend be-apiserver
   mode tcp
   option tcplog
   option tcp-check
   balance roundrobin 
   default-server inter 10s downinter 5s rise 2 fall 2 slowstart 60s maxconn 250 maxqueue 256 weight 100

       server master1 ${aws_instance.Master_nodes[0].private_ip}:6443 check
       server master2 ${aws_instance.Master_nodes[1].private_ip}:6443 check
       server master3 ${aws_instance.Master_nodes[2].private_ip}:6443 check 
EOT
systemctl restart haproxy 

#Installing kubectl with snap package manager
snap install kubectl --classic 
hostnamectl set-hostname lb_node
EOF
  tags = {
    Name = "lb_node"
  }
} 