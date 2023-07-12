resource "digitalocean_vpc" "kube_vpc" {
  name     = "kube-vpc"
  region   = "fra1"
  ip_range = "192.168.1.0/24"
}
