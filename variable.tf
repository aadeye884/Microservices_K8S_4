variable "master_node_count" {}
variable "ubuntu_ami" {}
variable "instance_type_medium" {}
variable "worker_node_count" {}
variable "ansible_sg_name" {}
variable "jenkins_sg_name" {}
variable "cluster_sg_name" {}
variable "port_jenkins" {}
variable "port_http" {}
variable "port_ssh" {}
variable "cluster_port" {}
variable "all_cidr" {}
variable "egress" {}
variable "instance_type_micro" {}
variable "usteam_bastion_ansible_name" {}

variable "redhat_ami_id" {}
variable "instance_type_medium2" {}
variable "jenkins_server_name" {}

variable "grafana_domain_hosted_zone" {}
variable "prometheus_domain_hosted_zone" {}
variable "prod_domain_hosted_zone" {}
variable "stage_domain_hosted_zone" {}

