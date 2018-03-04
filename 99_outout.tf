output "Azure Serveurs IP" {
  value = "${azurerm_public_ip.public_ip.*.ip_address}"
}

# 
# output "Amazon AWS Serveurs IP" {
#   value = ""
# }

