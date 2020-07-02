provider "azurerm" {
  features {}
}

data azurerm_subscription "this" {}

resource random_password "this" {
  length  = 32
  special = false
}

resource azuread_application_password "this" {
  application_object_id = azuread_application.this.id
  value                 = random_password.this.result
  end_date              = timeadd(timestamp(), "8766h")
  lifecycle {
    ignore_changes = [end_date]
  }
}

module "oidc" {
  source = "github.com/grantorchard/terraform-vault-module-oidc"

  azure_tenant_id    = data.azurerm_subscription.this.tenant_id
  oidc_client_id     = azuread_application.this.application_id
  oidc_client_secret = azuread_application_password.this.value
  web_redirect_uris  = [
    "http://localhost:8250/oidc/callback",
    "${var.vault_url}/ui/vault/auth/oidc/callback"
  ]
  default_role = "admin"
  token_policies = [
    vault_policy.admin.name
  ]
}

resource azuread_application "this" {
  name                       = "vault-oidc"
  reply_urls                 = [
    "http://localhost:8250/oidc/callback",
    "${var.vault_url}/ui/vault/auth/oidc/oidc/callback"
  ]
  required_resource_access {
    # Add MS Graph Group.Read.All API permissions
    resource_app_id = "00000003-0000-0000-c000-000000000000"

    resource_access {
      id   = "5b567255-7703-4780-807c-7be8301ae99b"
      type = "Scope"
    }
  }
  available_to_other_tenants = false
  oauth2_allow_implicit_flow = true
  type                       = "webapp/api"
}