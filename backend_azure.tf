resource vault_azure_secret_backend "azure-prod" {
  path            = "azure-prod"
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  environment     = "AzurePublicCloud"
}