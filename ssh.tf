resource "digitalocean_ssh_key" "sshkey" {
  name       = "sshkey"
  public_key = data.http.default_ssh_key.response_body
}

resource "digitalocean_ssh_key" "xenedium_ssh_key" {
  name       = "xenedium_ssh_key"
  public_key = data.http.xenedium_ssh_key.response_body
}

data "http" "default_ssh_key" {
  url = "https://cdn.abderraziq.com/k8s/id_rsa.pub"
}

data "http" "xenedium_ssh_key" {
  url = "https://abderraziq.com/id_rsa.pub"
}
