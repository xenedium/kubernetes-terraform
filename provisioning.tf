resource "null_resource" "control_plane_provisioning" {
  connection {
    host        = digitalocean_domain.control_plane_domain.name
    user        = "root"
    type        = "ssh"
    private_key = file(var.pvt_key_path)
    timeout     = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "curl https://cdn.abderraziq.com/k8s/init.sh | bash -s ${digitalocean_domain.control_plane_domain.name}"
    ]
  }
}

resource "null_resource" "node_one_provisioning" {
  connection {
    host        = digitalocean_domain.node_one_domain.name
    user        = "root"
    type        = "ssh"
    private_key = file(var.pvt_key_path)
    timeout     = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "curl https://cdn.abderraziq.com/k8s/init-node.sh | bash"
    ]
  }
}

resource "null_resource" "node_two_provisioning" {
  connection {
    host        = digitalocean_domain.node_two_domain.name
    user        = "root"
    type        = "ssh"
    private_key = file(var.pvt_key_path)
    timeout     = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "curl https://cdn.abderraziq.com/k8s/init-node.sh | bash"
    ]
  }
}

