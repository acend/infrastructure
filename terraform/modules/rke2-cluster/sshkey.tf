resource "tls_private_key" "terraform" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "hcloud_ssh_key" "terraform" {
  name       = "terraform"
  public_key = tls_private_key.terraform.public_key_openssh
}
