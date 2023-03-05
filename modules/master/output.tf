output "subnet_name" {
  value     = azurerm_subnet.kiratech.id
  sensitive = false
  depends_on = [
  ]
}

output "rsg_name" {
  value     = azurerm_resource_group.kiratech.name
  sensitive = false
  depends_on = [
  ]
}

output "rsg_location" {
  value     = azurerm_resource_group.kiratech.location
  sensitive = false
  depends_on = [
  ]
}