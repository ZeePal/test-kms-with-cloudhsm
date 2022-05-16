resource "aws_ssm_parameter" "cloudhsm_ca_cert" {
  type  = "SecureString"
  name  = "/test-kms-with-cloudhsm/cloudhsm_ca_cert"
  value = var.cloudhsm_ca_cert
}
