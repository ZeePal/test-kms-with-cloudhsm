variable "remote_terminal_ip" {}
variable "remote_terminal_ssh_private_key" {
  sensitive = true
}

variable "cloudhsm_ip" {}
variable "cloudhsm_ca_cert" {}
