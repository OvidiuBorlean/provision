output "admin_password" {
  value = random_string.password.result
}

output "ipaddress" {
  value = azurerm_public_ip.public_ip.ip_address
