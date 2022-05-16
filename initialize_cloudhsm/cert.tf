# Sign the CloudHSM CSR so it can be initialized
resource "tls_locally_signed_cert" "cloudhsm" {
  cert_request_pem   = var.cloudhsm_csr
  ca_private_key_pem = tls_private_key.ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca.cert_pem

  validity_period_hours = 24 * 3652

  allowed_uses = []

  lifecycle {
    # BUG?: Cluster certificates are not available after init?
    ignore_changes = [cert_request_pem]
  }
}
