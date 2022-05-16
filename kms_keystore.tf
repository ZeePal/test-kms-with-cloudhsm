# Create a unique name for the keystore in case this runs multiple times
resource "random_pet" "keystore" {}
locals {
  custom_key_store_name = "test-kms-with-cloudhsm-${random_pet.keystore.id}"
}

# Once the "kmsuser" is on the CloudHSM's, Create the KMS custom key store via the aws cli
resource "null_resource" "kms_keystore" {
  triggers = {
    custom_key_store_name = local.custom_key_store_name
    cloudhsm_cluster_id   = aws_cloudhsm_v2_cluster.this.cluster_id
    cloudhsm_ca_cert      = sha256(module.initialize_cloudhsm.ca_cert)
  }

  provisioner "local-exec" {
    command = join(" ", [
      "aws kms create-custom-key-store",
      "--custom-key-store-name '${local.custom_key_store_name}'",
      "--cloud-hsm-cluster-id '${aws_cloudhsm_v2_cluster.this.cluster_id}'",
      "--key-store-password '${random_password.cloudhsm_kmsuser_init_password.result}'",
      "--trust-anchor-certificate 'file://${path.root}/.terraform/tmp/ca.crt'"
    ])
  }

  # Cant delete until all KMS keys are deleted (in 7+ days)
  #  provisioner "local-exec" {
  #    when = destroy
  #    command = join(" ", [
  #      "aws kms delete-custom-key-store --custom-key-store-id",
  #      "'${data.external.key_store_id.result["CustomKeyStoreId"]}'"
  #    ])
  #  }

  depends_on = [module.create_kmsuser]
}

# Get the KMS custom key store ID via the aws cli
data "external" "key_store_id" {
  program = [
    "aws",
    "kms",
    "describe-custom-key-stores",
    "--custom-key-store-name",
    local.custom_key_store_name,
    "--query",
    "CustomKeyStores[0]",
    "--output",
    "json"
  ]

  depends_on = [null_resource.kms_keystore]
}

# Ask the KMS custom key store to connect to the CloudHSM(s)
resource "null_resource" "connect_custom_key_store" {
  triggers = {
    custom_key_store_id = data.external.key_store_id.result["CustomKeyStoreId"]
  }
  provisioner "local-exec" {
    command = "aws kms connect-custom-key-store --custom-key-store-id '${self.triggers.custom_key_store_id}'"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "aws kms disconnect-custom-key-store --custom-key-store-id '${self.triggers.custom_key_store_id}'"
  }
}

# Wait for the KMS custom key store to finish trying to connect to the CloudHSM(s)
resource "null_resource" "wait_for_key_store_connection" {
  triggers = {
    custom_key_store_id = data.external.key_store_id.result["CustomKeyStoreId"]
  }
  provisioner "local-exec" {
    command = "${path.module}/scripts/wait_for_key_store_connection '${self.triggers.custom_key_store_id}'"
  }

  depends_on = [null_resource.connect_custom_key_store]
}
