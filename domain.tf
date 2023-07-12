resource "digitalocean_domain" "control_plane_domain" {
  name       = "control.xenedium.me"
  ip_address = digitalocean_droplet.control_plane.ipv4_address
}
