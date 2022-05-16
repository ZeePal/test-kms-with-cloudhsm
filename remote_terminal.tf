# Create an ec2 instance that Terraform will use to run commands against the CloudHSM
module "remote_terminal" {
  source = "./remote_terminal"

  name      = "test-kms-with-cloudhsm"
  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.public_subnets[0]

  iam_policy = {
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "SSMParametersAccess"
        Effect   = "Allow"
        Action   = "ssm:GetParameter*"
        Resource = "arn:aws:ssm:*:*:parameter/test-kms-with-cloudhsm/*"
      },
      {
        Sid      = "MonitorCloudHSMClusterStatus"
        Effect   = "Allow"
        Action   = "cloudhsm:DescribeClusters"
        Resource = "*"
      }
    ]
  }
}

# Allow the "remote_terminal" to talk to CloudHSM
data "aws_security_group" "cloudhsm" {
  name   = "cloudhsm-${aws_cloudhsm_v2_cluster.this.cluster_id}-sg"
  vpc_id = module.vpc.vpc_id
}
resource "aws_security_group_rule" "cloudhsm_from_remote_terminal" {
  security_group_id        = data.aws_security_group.cloudhsm.id
  type                     = "ingress"
  protocol                 = "TCP"
  from_port                = 2223
  to_port                  = 2225
  source_security_group_id = module.remote_terminal.security_group_id
}


