master_node_count    = 3
ubuntu_ami           = "ami-0fcf52bcf5db7b003"
instance_type_medium = "t2.medium"
worker_node_count    = 3
#SG Variables
port_ssh                      = 22
egress                        = 0
ansible_sg_name               = "ansible_sg"
port_jenkins                  = 8080
jenkins_sg_name               = "jenkins_sg"
port_http                     = 80
all_cidr                      = "0.0.0.0/0"
cluster_port                  = 65535
cluster_sg_name               = "cluster_sg"
instance_type_micro           = "t2.micro"
usteam_bastion_ansible_name   = "bastion_ansible_server"
redhat_ami_id                 = "ami-0dda7e535b65b6469"
instance_type_medium2         = "t3.medium"
jenkins_server_name           = "jenkins-host"
grafana_domain_hosted_zone    = "grafana.volakinwand.com"
prometheus_domain_hosted_zone = "prometheus.volakinwand.com"
prod_domain_hosted_zone       = "production.volakinwand.com"
stage_domain_hosted_zone      = "stage.volakinwand.com"

