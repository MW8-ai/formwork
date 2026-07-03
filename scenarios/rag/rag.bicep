// RAG showcase: base Foundry + Azure AI Search + grounding-data storage,
// wired with managed identity RBAC only (no keys anywhere).
param baseName string
param location string = resourceGroup().location
param searchSku string = 'basic'   // cheapest tier that supports what RAG needs; 'free' has no semantic ranker
param tags object = { managedBy: 'formwork', scenario: 'rag' }

module base '../../infra/bicep/main.bicep' = {
  name: 'formwork-base'
  params: {
    baseName: baseName
    location: location
    tags: tags
    modelDeployments: [
      { name: 'gpt-4.1-mini', format: 'OpenAI', version: '2025-04-14', skuName: 'GlobalStandard', capacity: 1 }
      { name: 'text-embedding-3-small', format: 'OpenAI', version: '1', skuName: 'GlobalStandard', capacity: 1 }
    ]
  }
}

resource search 'Microsoft.Search/searchServices@2024-06-01-preview' = {
  name: 'srch-${baseName}'
  location: location
  tags: tags
  sku: { name: searchSku }
  identity: { type: 'SystemAssigned' }
  properties: {
    disableLocalAuth: true          // RBAC only, same rule as the base
    replicaCount: 1
    partitionCount: 1
  }
}

resource groundingStore 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: take(replace('st${baseName}rag', '-', ''), 24)
  location: location
  tags: tags
  sku: { name: 'Standard_LRS' }
  kind: 'StorageV2'
  properties: {
    allowBlobPublicAccess: false
    allowSharedKeyAccess: false     // identity-only, enforced
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
  }
}

// Search reads grounding data: Storage Blob Data Reader on the storage account.
resource searchReadsBlobs 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(groundingStore.id, search.id, 'blob-reader')
  scope: groundingStore
  properties: {
    principalId: search.identity.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions',
      '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1')
  }
}

// Foundry project queries the index: Search Index Data Reader on the search service.
resource projectReadsIndex 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(search.id, baseName, 'index-reader')
  scope: search
  properties: {
    principalId: base.outputs.projectPrincipalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions',
      '1407120a-92aa-4202-b7e9-c0e197c71c8f')
  }
}

output searchEndpoint string = 'https://${search.name}.search.windows.net'
output storageAccount string = groundingStore.name
output foundryEndpoint string = base.outputs.foundryEndpoint
