# Quick & Dirty method to spin up CloudHSM so KMS can use it
This was used to create a dev env for updating the aws terraform provider to be able to manage kms keys which are stored
in CloudHSM.

- ~43 Min to build/apply
- ~5 Min to "mostly" destroy
    - Resources not destroyed:
        - The KMS Custom Key Store (`test-kms-with-cloudhsm-${PET_NAME}`)
            - If the custom key store has any KMS keys (including pending deletion), it cant be deleted
        - KMS Keys (eg, `aws_kms_key.test`)
            - These will be scheduled for deletion after ~7 days but not yet destroyed/deleted
