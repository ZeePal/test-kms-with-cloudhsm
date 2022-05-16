resource "null_resource" "this" {
  connection {
    type        = "ssh"
    host        = var.remote_terminal_ip
    user        = "ec2-user"
    private_key = var.remote_terminal_ssh_private_key
    agent       = false
  }

  provisioner "file" {
    source      = "${path.module}/setup_cloudhsm_client"
    destination = "/tmp/setup_cloudhsm_client"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/setup_cloudhsm_client",
      "sudo /tmp/setup_cloudhsm_client '${var.cloudhsm_ip}'",
    ]
  }

  depends_on = [
    aws_ssm_parameter.cloudhsm_ca_cert,
  ]
}
