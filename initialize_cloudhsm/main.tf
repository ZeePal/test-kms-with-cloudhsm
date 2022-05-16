# Initialize the CloudHSM cluster with the signed CSR & CA certs
resource "null_resource" "cloudhsm_keys" {
  triggers = {
    cloudhsm_cluster_id = var.cloudhsm_cluster_id
    ca_cert             = sha256(tls_self_signed_cert.ca.cert_pem)
    cloudhsm_cert       = sha256(tls_locally_signed_cert.cloudhsm.cert_pem)
  }
  provisioner "local-exec" {
    command = join(" ", [
      "aws cloudhsmv2 initialize-cluster --cluster-id '${var.cloudhsm_cluster_id}'",
      "--signed-cert 'file://${local_file.cloudhsm_cert.filename}'",
      "--trust-anchor 'file://${local_file.ca_cert.filename}'"
    ])
  }
}

resource "local_file" "csr" {
  content  = var.cloudhsm_csr
  filename = "${path.root}/.terraform/tmp/cloudhsm.csr"
  lifecycle {
    ignore_changes = [content]
  }
}
resource "local_file" "ca_cert" {
  content  = tls_self_signed_cert.ca.cert_pem
  filename = "${path.root}/.terraform/tmp/ca.crt"
}
resource "local_file" "cloudhsm_cert" {
  content  = tls_locally_signed_cert.cloudhsm.cert_pem
  filename = "${path.root}/.terraform/tmp/cloudhsm.crt"
}
