resource "aws_ssm_parameter" "cloudhsm_admin_password" {
  type  = "SecureString"
  name  = "/test-kms-with-cloudhsm/cloudhsm_admin_password"
  value = var.cloudhsm_admin_password
}
