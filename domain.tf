resource "digitalocean_domain" "control_plane_domain" {
  name       = "control-plane-${random_id.domain_id.hex}.xenedium.me"
  ip_address = digitalocean_droplet.control_plane.ipv4_address
}

resource "digitalocean_domain" "node_one_domain" {
  name       = "node-one-${random_id.domain_id.hex}.xenedium.me"
  ip_address = digitalocean_droplet.node_one.ipv4_address
}

resource "digitalocean_domain" "node_two_domain" {
  name       = "node-two-${random_id.domain_id.hex}.xenedium.me"
  ip_address = digitalocean_droplet.node_two.ipv4_address
}

resource "random_id" "domain_id" {
  byte_length = 2
}
