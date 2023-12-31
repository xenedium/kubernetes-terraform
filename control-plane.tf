resource "digitalocean_droplet" "control_plane" {
  image    = "debian-12-x64"
  name     = "control-plane"
  region   = "fra1"
  size     = "s-2vcpu-4gb"
  vpc_uuid = digitalocean_vpc.kube_vpc.id
  ssh_keys = [digitalocean_ssh_key.sshkey.id, digitalocean_ssh_key.xenedium_ssh_key.id]
}
