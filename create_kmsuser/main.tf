resource "null_resource" "this" {
  connection {
    type        = "ssh"
    host        = var.remote_terminal_ip
    user        = "ec2-user"
    private_key = var.remote_terminal_ssh_private_key
    agent       = false
  }

  provisioner "file" {
    source      = "${path.module}/create_kmsuser"
    destination = "/tmp/create_kmsuser"
  }
  provisioner "file" {
    source      = "${path.module}/create_kmsuser.expect"
    destination = "/tmp/create_kmsuser.expect"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/create_kmsuser",
      "chmod +x /tmp/create_kmsuser.expect",
      "sudo /tmp/create_kmsuser '${var.second_cloudhsm_ip}'",
    ]
  }

  depends_on = [
    aws_ssm_parameter.cloudhsm_kmsuser_init_password,
  ]
}
