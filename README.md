### This repository is a refactored version of [this](https://github.com/hashicorp/vault-guides/tree/master/operations/aws-kms-unseal/terraform-aws) guide

All credits go to the author of the guide mentioned above. 

Refactoring includes :

- Placing comments to the resources,explaining what they do.
- Separating resources into files.
- Making Vault EC2 dependent on the `tls_private_key`

### How to use the repo :

- Execute `git clone https://github.com/martinhristov90/vault_kms_aws_tf.git`
- cd `vault_kms_aws_tf`
- Execute `terraform init`, `terraform plan`, `terraform apply`

### Quick guide for using AWS KMS

- Login to the Vault server with command displayed when `terraform apply` finishes.
- When login execute `vault operator init -recovery-shares=1 -recovery-threshold=1`.
    > Please, note that `-recovery-shares=1 -recovery-threshold=1` is used instead of `-key-shares -key-threshold`, better explained [here](https://www.vaultproject.io/docs/enterprise/hsm/behavior.html)
- Recovery key is going to be returned to you, as well as root token, there is a difference between recovery key and unseal key, both can use SSS (Shamir Shared Secret).
- Run `vault status` you should see output like this:
```
---                      -----
Recovery Seal Type       shamir # Recovery keys are using SSS, check the article above.
Initialized              true
Sealed                   false
Total Recovery Shares    1
Threshold                1
Version                  1.3.0
Cluster Name             vault-cluster-484b9a73
Cluster ID               b7400fa3-8bb3-401d-2087-66cb00e31f67
HA Enabled               false
```
- When Vault is restarted with `sudo systemctl restart vault` it will start in `unsealed` stated, AWS KMS is acting to Vault as HSM.

### To migrate to using SSS for seal do the following:

- Shutdown Vault using `sudo systemctl stop vault`.
- Open `vault.hcl` using `sudo vi sudo vi /etc/vault.d/vault.hcl`
- Modify your `seal "aws_kms"` stanza to look like this :
```
seal "awskms" {
  region     = "us-east-1"
  kms_key_id = "the key id of your AWS KMS key is going to appear here (terraform templete placed it here)"
  disabled   = "true"
}
```
> You cannot remote the `region` and `kms_key_id` parameters (you will get an error), just add the last line.
- Start vault with `sudo systemctl start vault`, when you look at the logs of the `vault.service` with `journalctl -u vault` you should see this line :
```
4T08:12:44.179Z [WARN]  core: entering seal migration mode; Vault will not automatically unseal even if using an automatically unseal even if using an autoseal: from_barrier_type=awskms to_barrier_type=shamir
```
> The `migration` process has began, `vault status` is going to show `Sealed : true`
- TO BE CONTINUED


