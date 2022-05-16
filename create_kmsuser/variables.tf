variable "remote_terminal_ip" {}
variable "remote_terminal_ssh_private_key" {
  sensitive = true
}

variable "cloudhsm_kmsuser_init_password" {
  sensitive = true
}
variable "second_cloudhsm_ip" {}
