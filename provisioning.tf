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
      "#!/bin/bash",
      "curl https://cdn.abderraziq.com/k8s/init.sh | bash -s ${digitalocean_domain.control_plane_domain.name}",
      "sed -i 's/0.0.0.0/${digitalocean_droplet.control_plane.ipv4_address}/g' mlb.yaml",
      "sed -i 's/1.1.1.1/${digitalocean_droplet.node_one.ipv4_address}/g' mlb.yaml",
      "sed -i 's/2.2.2.2/${digitalocean_droplet.node_two.ipv4_address}/g' mlb.yaml"
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
      "curl https://cdn.abderraziq.com/k8s/init-node.sh | bash -s ${digitalocean_domain.control_plane_domain.name}:6443 ${data.external.kube_token.result["result"]} ${data.external.kube_token_hash.result["result"]}"
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
      "curl https://cdn.abderraziq.com/k8s/init-node.sh | bash -s -s ${digitalocean_domain.control_plane_domain.name}:6443 ${data.external.kube_token.result["result"]} ${data.external.kube_token_hash.result["result"]}"
    ]
  }
}

data "external" "kube_token" {
  program    = ["sh", "-c", "ssh -i ssh/id_rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@${digitalocean_domain.control_plane_domain.name} 'curl https://cdn.abderraziq.com/k8s/get-kube-token.sh | bash'"]
  depends_on = [null_resource.control_plane_provisioning]
}

data "external" "kube_token_hash" {
  program    = ["sh", "-c", "ssh -i ssh/id_rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@${digitalocean_domain.control_plane_domain.name} 'curl https://cdn.abderraziq.com/k8s/get-token-hash.sh | bash'"]
  depends_on = [null_resource.control_plane_provisioning]
}

data "external" "apply_mlb" {
  program    = ["sh", "-c", "ssh -i ssh/id_rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@${digitalocean_domain.control_plane_domain.name} 'KUBECONFIG=/etc/kubernetes/admin.conf kubectl apply -f mlb.yaml'"]
  depends_on = [null_resource.node_one_provisioning, null_resource.node_two_provisioning]
}
