resource "digitalocean_droplet" "control_plane" {
  image    = "debian-12-x64"
  name     = "control-plane"
  region   = "fra1"
  size     = "s-2vcpu-4gb"
  vpc_uuid = digitalocean_vpc.kube_vpc.id
  ssh_keys = [digitalocean_ssh_key.sshkey.id, digitalocean_ssh_key.xenedium_ssh_key.id]

  connection {
    host        = self.ipv4_address
    user        = "root"
    type        = "ssh"
    private_key = file(var.pvt_key_path)
    timeout     = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "curl https://cdn.abderraziq.com/k8s/init.sh | bash"
    ]
  }
}
