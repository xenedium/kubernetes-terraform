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
      "curl https://cdn.abderraziq.com/k8s/init.sh | bash -s ${digitalocean_domain.control_plane_domain.name}",
      "openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //' > hash.txt"
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
      "curl https://cdn.abderraziq.com/k8s/init-node.sh | bash -s ${digitalocean_domain.control_plane_domain.name}:6443 ${data.external.kube_token.result} ${data.external.kube_token_hash.result}"
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
      "curl https://cdn.abderraziq.com/k8s/init-node.sh | bash -s -s ${digitalocean_domain.control_plane_domain.name}:6443 ${data.external.kube_token.result} ${data.external.kube_token_hash.result}"
    ]
  }
}

data "external" "kube_token" {
  program    = ["sh", "-c", "ssh -i ssh/id_rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@${digitalocean_domain.control_plane_domain.name} 'kubeadm token create'"]
  depends_on = [null_resource.control_plane_provisioning]
}

data "external" "kube_token_hash" {
  program    = ["sh", "-c", "ssh -i ssh/id_rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@${digitalocean_domain.control_plane_domain.name} 'cat hash.txt'"]
  depends_on = [null_resource.control_plane_provisioning]
}
