# Creation du reseau
resource "azurerm_virtual_network" "vnet" {
  name                = "virtualNetwork1"
  resource_group_name = "${var.rg}"
  address_space       = ["10.0.0.0/16"]
  location            = "canadaeast"

  tags {
    environment = "terraform-demo"
  }
}

# creation du sous reseau IP ou sera installe les ressources
resource "azurerm_subnet" "subnet1" {
  name                 = "subnet1"
  resource_group_name  = "${var.rg}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefix       = "10.0.2.0/24"
}

# Creation d'une addresse IP qui sera attachee au serveur
resource "azurerm_public_ip" "public_ip" {
  name                         = "terraform-demo1"
  location                     = "canadaeast"
  resource_group_name          = "${var.rg}"
  public_ip_address_allocation = "dynamic"

  tags {
    environment = "terraform-demo"
  }
}

# Creation de la carte reseau On y attache l'adresse IP cree precedement
# On les cree dans le sous reseau prealablement cree
resource "azurerm_network_interface" "network_interface" {
  name                = "terraform-demo1"
  location            = "canadaeast"
  resource_group_name = "${var.rg}"

  ip_configuration {
    name                          = "terraform-demo1"
    subnet_id                     = "${azurerm_subnet.subnet1.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.public_ip.id}"
  }

  tags {
    environment = "terraform-demo"
  }
}

resource "azurerm_network_security_group" "security_group" {
  name                = "terraform-demo"
  location            = "canadaeast"
  resource_group_name = "${var.rg}"

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags {
    environment = "terraform-demo"
  }
}

# resource "random_id" "randomId" {
#   keepers = {
#     # Generate a new ID only when a new resource group is defined
#     resource_group = "${var.rg}"
#   }
#
#   byte_length = 8
# }

# resource "azurerm_storage_account" "mystorageaccount" {
#   name                     = "diag${random_id.randomId.hex}"
#   resource_group_name      = "${var.rg}"
#   location                 = "canadaeast"
#   account_replication_type = "LRS"
#   account_tier             = "Standard"
#
#   tags {
#     environment = "terraform-demo"
#   }
# }

resource "azurerm_virtual_machine" "myterraformvm" {
  name                          = "terraform-demo1"
  location                      = "canadaeast"
  resource_group_name           = "${var.rg}"
  network_interface_ids         = ["${azurerm_network_interface.network_interface.id}"]
  vm_size                       = "Standard_DS1_v2"
  delete_os_disk_on_termination = true

  storage_os_disk {
    name              = "myOsDiskdemo1"
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

  # boot_diagnostics {
  #   enabled     = "true"
  #   storage_uri = "${azurerm_storage_account.mystorageaccount.primary_blob_endpoint}"
  # }

  tags {
    environment = "terraform-demo"
  }
}

resource "azurerm_virtual_machine_extension" "nginx" {
  name                 = "${azurerm_virtual_machine.myterraformvm.name}"
  location             = "canadaeast"
  resource_group_name  = "${var.rg}"
  virtual_machine_name = "${azurerm_virtual_machine.myterraformvm.name}"
  publisher            = "Microsoft.OSTCExtensions"
  type                 = "CustomScriptForLinux"
  type_handler_version = "1.2"

  settings = <<SETTINGS
    {
        "fileUris": ["https://github.com/fmedery/terraform-demo/blob/master/scripts/azure.sh"],
        "commandToExecute": "/bin/bash ./azure.sh"
      }
SETTINGS

  tags {
    environment = "terraform-demo"
  }
}
