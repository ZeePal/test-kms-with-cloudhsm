resource "tls_private_key" "this" {
  algorithm = "ED25519"
}

resource "aws_key_pair" "this" {
  key_name   = "remote-terminal-${var.name}"
  public_key = trimspace(tls_private_key.this.public_key_openssh)
}
