# Formwork base (Terraform mirror of infra/bicep/main.bicep).
# Uses azapi against the same Microsoft.CognitiveServices resources for exact
# parity with Bicep and zero provider lag on new Foundry features.
# Enterprise alternative: Azure/avm-ptn-aiml-ai-foundry/azurerm (AVM pattern module).

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

resource "azurerm_log_analytics_workspace" "logs" {
  name                = "log-${var.base_name}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days
  tags                = var.tags
}

resource "azapi_resource" "foundry" {
  type      = "Microsoft.CognitiveServices/accounts@2025-06-01"
  name      = "aif-${var.base_name}"
  location  = var.location
  parent_id = data.azurerm_resource_group.rg.id
  tags      = var.tags

  identity { type = "SystemAssigned" }

  body = {
    kind = "AIServices"
    sku  = { name = "S0" }
    properties = {
      allowProjectManagement = true
      customSubDomainName    = "aif-${var.base_name}"
      disableLocalAuth       = var.disable_local_auth
      publicNetworkAccess    = var.public_network_enabled ? "Enabled" : "Disabled"
    }
  }

  schema_validation_enabled = false
}

resource "azapi_resource" "project" {
  type      = "Microsoft.CognitiveServices/accounts/projects@2025-06-01"
  name      = "proj-${var.base_name}"
  location  = var.location
  parent_id = azapi_resource.foundry.id

  identity { type = "SystemAssigned" }

  body = { properties = {} }

  schema_validation_enabled = false
}

resource "azapi_resource" "model" {
  for_each  = { for m in var.model_deployments : m.name => m }
  type      = "Microsoft.CognitiveServices/accounts/deployments@2025-06-01"
  name      = each.value.name
  parent_id = azapi_resource.foundry.id

  body = {
    sku = { name = each.value.sku_name, capacity = each.value.capacity }
    properties = {
      model = { name = each.value.name, format = each.value.format, version = each.value.version }
    }
  }

  schema_validation_enabled = false
}

resource "azurerm_monitor_diagnostic_setting" "diag" {
  name                       = "diag-${var.base_name}"
  target_resource_id         = azapi_resource.foundry.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.logs.id

  enabled_log { category_group = "audit" }
  enabled_log { category_group = "allLogs" }
}
