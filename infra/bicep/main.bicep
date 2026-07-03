// Formwork base: hardened-by-default Azure AI Foundry install.
// Grounded in microsoft-foundry/foundry-samples 00-basic, with security defaults raised.
// Scenarios overlay this base via parameter files in /scenarios — they cannot opt out.

@description('Base name; used for the Foundry account and derived resource names.')
@minLength(3)
@maxLength(20)
param baseName string

@description('Azure region. GlobalStandard model SKUs deploy from most regions.')
param location string = resourceGroup().location

@description('Entra-only auth. Keep true. Local keys are a standing credential risk.')
param disableLocalAuth bool = true

@description('Public network access. Enabled for personal showcase; set false + private endpoints for work/GCC.')
param publicNetworkEnabled bool = true

@description('Model deployments. Each: { name, format, version, skuName, capacity }.')
param modelDeployments array = []

@description('Log Analytics retention in days (31 = cheapest that still shows real ops discipline).')
param logRetentionDays int = 31

param tags object = {
  managedBy: 'formwork'
  standard: 'architects-cornerstone'
}

resource logs 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: 'log-${baseName}'
  location: location
  tags: tags
  properties: {
    sku: { name: 'PerGB2018' }
    retentionInDays: logRetentionDays
  }
}

// An AI Foundry resource is a variant of the CognitiveServices/accounts type.
resource foundry 'Microsoft.CognitiveServices/accounts@2025-06-01' = {
  name: 'aif-${baseName}'
  location: location
  tags: tags
  kind: 'AIServices'
  sku: { name: 'S0' }
  identity: { type: 'SystemAssigned' }
  properties: {
    allowProjectManagement: true          // required for Foundry projects
    customSubDomainName: 'aif-${baseName}'
    disableLocalAuth: disableLocalAuth    // Entra ID only by default
    publicNetworkAccess: publicNetworkEnabled ? 'Enabled' : 'Disabled'
  }
}

resource project 'Microsoft.CognitiveServices/accounts/projects@2025-06-01' = {
  name: 'proj-${baseName}'
  parent: foundry
  location: location
  identity: { type: 'SystemAssigned' }
  properties: {}
}

@batchSize(1) // model deployments must be serialized
resource deployments 'Microsoft.CognitiveServices/accounts/deployments@2025-06-01' = [
  for m in modelDeployments: {
    name: m.name
    parent: foundry
    sku: { name: m.skuName, capacity: m.capacity }
    properties: {
      model: { name: m.name, format: m.format, version: m.version }
    }
  }
]

// Every install ships audit logging. Non-negotiable across scenarios.
resource diag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-${baseName}'
  scope: foundry
  properties: {
    workspaceId: logs.id
    logs: [
      { categoryGroup: 'audit', enabled: true }
      { categoryGroup: 'allLogs', enabled: true }
    ]
  }
}

output foundryName string = foundry.name
output foundryEndpoint string = foundry.properties.endpoint
output projectName string = project.name
output foundryPrincipalId string = foundry.identity.principalId
output projectPrincipalId string = project.identity.principalId
output logAnalyticsId string = logs.id
