resource "aws_ssm_parameter" "cloudhsm_kmsuser_init_password" {
  type  = "SecureString"
  name  = "/test-kms-with-cloudhsm/cloudhsm_kmsuser_init_password"
  value = var.cloudhsm_kmsuser_init_password
}
