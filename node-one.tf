resource "digitalocean_droplet" "node_one" {
  image    = "debian-12-x64"
  name     = "node-one"
  region   = "fra1"
  size     = "s-2vcpu-2gb"
  vpc_uuid = digitalocean_vpc.kube_vpc.id
  ssh_keys = [digitalocean_ssh_key.sshkey.id, digitalocean_ssh_key.xenedium_ssh_key.id]
}
