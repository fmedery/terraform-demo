# Creation de la machine virtuelle
resource "azurerm_virtual_machine" "myterraformvm" {
  count                         = "${var.nbr}"
  name                          = "terraform-demo2-${count.index +1}"
  location                      = "canadaeast"
  resource_group_name           = "${var.rg}"
  network_interface_ids         = ["${element(azurerm_network_interface.network_interface.*.id, count.index)}"]
  vm_size                       = "Standard_DS1_v2"
  delete_os_disk_on_termination = true

  # creation de disque
  storage_os_disk {
    name              = "myOsDisk2-${count.index +1}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  # choix de l'OS
  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04.0-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = "myvm"
    admin_username = "azureuser"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    # depoyment d'une clee SSH
    ssh_keys {
      path     = "/home/azureuser/.ssh/authorized_keys"
      key_data = "${var.ssh_public_key}"
    }
  }

  tags {
    environment = "terraform-demo"
  }
}

# utilisation d'un script pour installer nginx et le index.html
resource "azurerm_virtual_machine_extension" "nginx" {
  count                = "${var.nbr}"
  name                 = "terraform-demo${count.index +1}"
  location             = "canadaeast"
  resource_group_name  = "${var.rg}"
  virtual_machine_name = "${element(azurerm_virtual_machine.myterraformvm.*.name, count.index )}"
  publisher            = "Microsoft.OSTCExtensions"
  type                 = "CustomScriptForLinux"
  type_handler_version = "1.2"

  settings = <<SETTINGS
    {
      "fileUris": ["https://raw.githubusercontent.com/fmedery/terraform-demo/master/scripts/azure.sh"],
      "commandToExecute": "/bin/bash ./azure.sh demo2"
    }
SETTINGS

  tags {
    environment = "terraform-demo"
  }
}
