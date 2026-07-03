output "foundry_name" {
  value = azapi_resource.foundry.name
}

output "foundry_endpoint" {
  value = azapi_resource.foundry.output.properties.endpoint
}

output "project_name" {
  value = azapi_resource.project.name
}

output "foundry_principal_id" {
  value = azapi_resource.foundry.identity[0].principal_id
}

output "project_principal_id" {
  value = azapi_resource.project.identity[0].principal_id
}
