resource "null_resource" "this" {
  connection {
    type        = "ssh"
    host        = var.remote_terminal_ip
    user        = "ec2-user"
    private_key = var.remote_terminal_ssh_private_key
    agent       = false
  }

  provisioner "file" {
    source      = "${path.module}/activate_cloudhsm"
    destination = "/tmp/activate_cloudhsm"
  }
  provisioner "file" {
    source      = "${path.module}/activate_cloudhsm.expect"
    destination = "/tmp/activate_cloudhsm.expect"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/activate_cloudhsm",
      "chmod +x /tmp/activate_cloudhsm.expect",
      "sudo /tmp/activate_cloudhsm",
    ]
  }

  depends_on = [
    aws_ssm_parameter.cloudhsm_admin_password,
  ]
}
