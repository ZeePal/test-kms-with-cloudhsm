# Create a CA so we can sign the CloudHSM CSR
resource "tls_private_key" "ca" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "ca" {
  private_key_pem = tls_private_key.ca.private_key_pem

  is_ca_certificate     = true
  validity_period_hours = 24 * 3652

  subject {
    common_name  = "test-kms-with-cloudhsm.local"
    organization = "Test KMS With CloudHSM"
  }

  allowed_uses = []
}
