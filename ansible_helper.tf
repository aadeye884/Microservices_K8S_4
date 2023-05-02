#This resource will help us to create a host inventory file from inventory.tftpl
resource "local_file" "inventory" {
  content = templatefile("${path.root}/templates/inventory.tftpl",
    {
      masters-dns = aws_instance.Master_nodes.*.private_dns,
      masters-ip  = aws_instance.Master_nodes.*.private_ip,
      workers-dns = aws_instance.Worker_nodes.*.private_dns,
      workers-ip  = aws_instance.Worker_nodes.*.private_ip,
      haproxy-dns = aws_instance.lb_node.*.private_dns,
      haproxy-ip  = aws_instance.lb_node.*.private_ip
    }
  )
  filename = "${path.root}/inventory"
}

#Time sleep resource allow us to wait for the ansible server to be fully provision before other resources can interact with it
resource "time_sleep" "waiting_for_ansible" {
  depends_on      = [aws_instance.bastion_ansible_server]
  create_duration = "120s"
}

# This null resource helps to copy ansible server after waiting for the ansible server to be provisioned
resource "null_resource" "copying_inventory_file_into_ansible" {
  depends_on = [time_sleep.waiting_for_ansible]
  provisioner "file" {
    source      = "${path.root}/inventory"
    destination = "/home/ubuntu/inventory"
    connection {
      type        = "ssh"
      host        = aws_instance.bastion_ansible_server.public_ip
      user        = "ubuntu"
      private_key = tls_private_key.us_teamkeypair.private_key_pem
      agent       = false
      insecure    = true
    }
  }
}

# This file will be creating our ansible variable file and in this file we are providing our master node IP, our haproxy IP, and our GIT credentials
resource "local_file" "ansible_variable_file" {
  content  = <<-DOC
        master_ip: ${aws_instance.Master_nodes[0].private_ip}
        haproxy_ip: ${aws_instance.lb_node.private_ip}
        username: fmbaba2904
        password: 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
        DOC
  filename = "ansible/ansible_vars_file.yml"
}

# This resource copies our playbooks and variable file into the ansible server.
resource "null_resource" "copying_ansible_playbooks" {
  depends_on = [time_sleep.waiting_for_ansible, local_file.ansible_variable_file]
  provisioner "file" {
    source      = "${path.root}/ansible"
    destination = "/home/ubuntu/ansible/"
    connection {
      type        = "ssh"
      host        = aws_instance.bastion_ansible_server.public_ip
      user        = "ubuntu"
      private_key = tls_private_key.us_teamkeypair.private_key_pem
      agent       = false
      insecure    = true
    }
  }
}

# Using provisioner "remote-exec" to install kubernetes on all servers.
resource "null_resource" "installing_kubernetes" {
  depends_on = [time_sleep.waiting_for_ansible, local_file.ansible_variable_file, aws_instance.Master_nodes, aws_instance.Worker_nodes]
  provisioner "remote-exec" {
    inline = [
      "echo 'installing kubernetes on all servers...'",
      "sleep 60 && ansible-playbook -i /home/ubuntu/inventory /home/ubuntu/ansible/kubernetes-installation.yml",
    ]
    connection {
      type        = "ssh"
      host        = aws_instance.bastion_ansible_server.public_ip
      user        = "ubuntu"
      private_key = tls_private_key.us_teamkeypair.private_key_pem
      agent       = false
      insecure    = true
    }
  }
}

# This resource is creating our clusters
resource "null_resource" "initializing_cluster" {
  depends_on = [time_sleep.waiting_for_ansible, local_file.ansible_variable_file, aws_instance.Master_nodes, aws_instance.Worker_nodes, null_resource.installing_kubernetes]
  provisioner "remote-exec" {
    inline = [
      "echo 'initializing cluster...'",
      "sleep 60 && ansible-playbook -i /home/ubuntu/inventory /home/ubuntu/ansible/cluster-initialization.yml",
    ]
    connection {
      type        = "ssh"
      host        = aws_instance.bastion_ansible_server.public_ip
      user        = "ubuntu"
      private_key = tls_private_key.us_teamkeypair.private_key_pem
      agent       = false
      insecure    = true
    }
  }
}

# This resource is to deploy our application manifest from GitHub
resource "null_resource" "deploy_application" {
  depends_on = [time_sleep.waiting_for_ansible, local_file.ansible_variable_file, aws_instance.Master_nodes, aws_instance.Worker_nodes, null_resource.installing_kubernetes, null_resource.initializing_cluster]
  provisioner "remote-exec" {
    inline = [
      "echo 'deploy application...'",
      "sleep 30 && ansible-playbook -i /home/ubuntu/inventory /home/ubuntu/ansible/staging.yml",
      "sleep 30 && ansible-playbook -i /home/ubuntu/inventory /home/ubuntu/ansible/prod.yml",
      "sleep 30 && ansible-playbook -i /home/ubuntu/inventory /home/ubuntu/ansible/monitoring.yml",
    ]
    connection {
      type        = "ssh"
      host        = aws_instance.bastion_ansible_server.public_ip
      user        = "ubuntu"
      private_key = tls_private_key.us_teamkeypair.private_key_pem
      agent       = false
      insecure    = true
    }
  }
}