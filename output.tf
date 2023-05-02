output "master_nodes_ip" {
  value = aws_instance.Master_nodes.*.private_ip # * means that all the private ips of all master nodes will be listed in the output 
}

output "Worker_nodes_private_ip" {
  value = aws_instance.Worker_nodes.*.private_ip # * means that all the private ips of all worker nodes will be listed in the output
}

output "ansible-ip" {
  value = aws_instance.bastion_ansible_server.public_ip
}
output "jenkin-ip" {
  value = aws_instance.jenkins_server.public_ip
}
output "prometheus_lb" {
  value = aws_lb.prometheus-lb.dns_name
}
output "grafana_lb" {
  value = aws_lb.grafana-lb.dns_name
}
output "production_lb" {
  value = aws_lb.PROD-worker-lb.dns_name
}
output "stage_lb" {
  value = aws_lb.stage-worker-lb.dns_name
}
output "haproxy_ip" {
  value = aws_instance.lb_node.public_ip
}
