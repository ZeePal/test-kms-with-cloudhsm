# Order of resources below is intended to be the order to be spun up


resource "aws_cloudhsm_v2_cluster" "this" {
  hsm_type   = "hsm1.medium"
  subnet_ids = module.vpc.private_subnets
}

# KMS needs 2 HSM's but you can only spin up 1 until you have "activated" the CLoudHSM cluster first
resource "aws_cloudhsm_v2_hsm" "first" {
  cluster_id = aws_cloudhsm_v2_cluster.this.cluster_id
  subnet_id  = module.vpc.private_subnets[0]
}
# Get IP of the first HSM
data "aws_network_interface" "first" {
  id = aws_cloudhsm_v2_hsm.first.hsm_eni_id
}

# CSR only available after first HSM is up
data "aws_cloudhsm_v2_cluster" "this" {
  cluster_id = aws_cloudhsm_v2_cluster.this.cluster_id

  depends_on = [aws_cloudhsm_v2_hsm.first]
}

# Generate the CA, sign the CSR & push signed cert to CloudHSM
module "initialize_cloudhsm" {
  source = "./initialize_cloudhsm"

  cloudhsm_cluster_id = aws_cloudhsm_v2_cluster.this.cluster_id
  # BUG?: CloudHSM Cluster certificates are not available after being initilized?
  cloudhsm_csr = length(data.aws_cloudhsm_v2_cluster.this.cluster_certificates) > 0 ? data.aws_cloudhsm_v2_cluster.this.cluster_certificates[0].cluster_csr : ""
}

# Configure the remote terminal to connect to the first HSM
module "setup_cloudhsm_client" {
  source = "./setup_cloudhsm_client"

  remote_terminal_ip              = module.remote_terminal.ip
  remote_terminal_ssh_private_key = module.remote_terminal.ssh_private_key

  cloudhsm_ip      = data.aws_network_interface.first.private_ip
  cloudhsm_ca_cert = module.initialize_cloudhsm.ca_cert
}

# Use the remote terminal to connect to the first HSM & update the "admin" password
module "activate_cloudhsm" {
  source = "./activate_cloudhsm"

  remote_terminal_ip              = module.remote_terminal.ip
  remote_terminal_ssh_private_key = module.remote_terminal.ssh_private_key

  cloudhsm_admin_password = random_password.cloudhsm_admin_password.result

  depends_on = [
    module.setup_cloudhsm_client,
    aws_security_group_rule.cloudhsm_from_remote_terminal,
  ]
}

# Create the second HSM ready for KMS
resource "aws_cloudhsm_v2_hsm" "second" {
  cluster_id = aws_cloudhsm_v2_cluster.this.cluster_id
  subnet_id  = module.vpc.private_subnets[1]

  # Cluster can't have more than 1 HSM without being activated first
  depends_on = [module.activate_cloudhsm]
}
# Get the second HSM's ip address
data "aws_network_interface" "second" {
  id = aws_cloudhsm_v2_hsm.second.hsm_eni_id
}

# Use the remote terminal to connect to both HSM's & create the "kmsuser"
module "create_kmsuser" {
  source = "./create_kmsuser"

  remote_terminal_ip              = module.remote_terminal.ip
  remote_terminal_ssh_private_key = module.remote_terminal.ssh_private_key

  second_cloudhsm_ip             = data.aws_network_interface.second.private_ip
  cloudhsm_kmsuser_init_password = random_password.cloudhsm_kmsuser_init_password.result
}
