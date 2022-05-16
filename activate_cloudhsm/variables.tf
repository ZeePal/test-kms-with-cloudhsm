variable "remote_terminal_ip" {}
variable "remote_terminal_ssh_private_key" {
  sensitive = true
}

variable "cloudhsm_admin_password" {
  sensitive = true
}
