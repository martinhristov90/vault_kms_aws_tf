# Here the actual KMS symetric key is created.
resource "aws_kms_key" "vault" {
  description             = "Vault unseal key"
  deletion_window_in_days = 10 # Delete in 10 days

  tags = {
    Name = "vault-kms-unseal-${random_pet.env.id}" # All resources will be tagged this way
  }
}



