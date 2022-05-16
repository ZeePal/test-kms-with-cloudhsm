# Create a password for the CloudHSM so the CloudHSM can be "activated"
resource "random_password" "cloudhsm_admin_password" {
  length  = 22
  special = false
}

# Create the initial password for the "kmsuser" (kms changes/rotates this on its own)
resource "random_password" "cloudhsm_kmsuser_init_password" {
  length  = 22
  special = false
}
