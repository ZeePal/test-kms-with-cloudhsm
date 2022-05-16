output "ca_cert" {
  value = tls_self_signed_cert.ca.cert_pem
}
