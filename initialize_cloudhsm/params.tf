resource "aws_ssm_parameter" "cloudhsm_cluster_id" {
  type  = "SecureString"
  name  = "/test-kms-with-cloudhsm/cloudhsm_cluster_id"
  value = var.cloudhsm_cluster_id
}
