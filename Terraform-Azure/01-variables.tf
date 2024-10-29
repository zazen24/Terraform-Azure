#================================================================================================
# Environment Vars - Global
#================================================================================================
variable "tenant_id" {}        # The azure tenant id.
variable "terraform_sp" {}     # The terraform service principal.
variable "location" {
    default = "australiaeast"
}         # Azure location to deploy resources in.
variable "application_code" {
    default = "az-aks"
} # Project code used for naming.
variable "unique_id" {
    default = "12345"
}        # A unique id for naming.

#================================================================================================
# Environment Vars
#================================================================================================
variable "environment" {
    default = "test"
}     # The environment name.
variable "subscription_id" {} # The subscription id.

#================================================================================================
# Key Vault Policies
#================================================================================================
variable "keyvault_policies" {} # Key vault policies.