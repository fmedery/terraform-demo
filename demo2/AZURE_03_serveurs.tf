resource "random_id" "randomId" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = "${var.rg}"
  }

  byte_length = 8
}

resource "azurerm_storage_account" "mystorageaccount" {
  name                     = "diag${random_id.randomId.hex}"
  resource_group_name      = "${var.rg}"
  location                 = "eastus"
  account_replication_type = "LRS"
  account_tier             = "Standard"

  tags {
    environment = "terraform-demo"
  }
}

resource "azurerm_virtual_machine" "myterraformvm" {
  count                         = "${var.nbr}"
  name                          = "terraform-demo${count.index +1}"
  location                      = "eastus"
  resource_group_name           = "${var.rg}"
  network_interface_ids         = ["${element(azurerm_network_interface.network_interface.*.id, count.index)}"]
  vm_size                       = "Standard_DS1_v2"
  delete_os_disk_on_termination = true

  storage_os_disk {
    name              = "myOsDisk${count.index +1}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

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

    ssh_keys {
      path     = "/home/azureuser/.ssh/authorized_keys"
      key_data = "${var.ssh_public_key}"
    }
  }

  boot_diagnostics {
    enabled     = "true"
    storage_uri = "${azurerm_storage_account.mystorageaccount.primary_blob_endpoint}"
  }

  tags {
    environment = "terraform-demo"
  }
}

resource "azurerm_virtual_machine_extension" "nginx" {
  count                = "${var.nbr}"
  name                 = "terraform-demo${count.index +1}"
  location             = "eastus"
  resource_group_name  = "${var.rg}"
  virtual_machine_name = "${element(azurerm_virtual_machine.myterraformvm.*.name, count.index )}"
  publisher            = "Microsoft.OSTCExtensions"
  type                 = "CustomScriptForLinux"
  type_handler_version = "1.2"

  settings = <<SETTINGS
    {
        "fileUris": ["https://github.com/fmedery/terraform-demo/blob/master/scripts/azure.sh"],
        "commandToExecute": "./azure.sh demo2"
      }
SETTINGS

  tags {
    environment = "terraform-demo"
  }
}
