resource "azurerm_public_ip" "public_ip1" {
  name                         = "terraform-demo1"
  location                     = "eastus"
  resource_group_name          = "${var.rg}"
  public_ip_address_allocation = "dynamic"

  tags {
    environment = "terraform-demo"
  }
}

resource "azurerm_network_security_group" "security_group" {
  name                = "terraform-demo"
  location            = "eastus"
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

  tags {
    environment = "terraform-demo"
  }
}

resource "azurerm_network_interface" "network_interface" {
  name                = "terraform-demo1"
  location            = "eastus"
  resource_group_name = "${var.rg}"

  ip_configuration {
    name                          = "terraform-demo"
    subnet_id                     = "${data.azurerm_subnet.subnet.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.public_ip1.id}"
  }

  tags {
    environment = "terraform-demo"
  }
}

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
  name                  = "terraform-demo1"
  location              = "eastus"
  resource_group_name   = "${var.rg}"
  network_interface_ids = ["${azurerm_network_interface.network_interface.id}"]
  vm_size               = "Standard_DS1_v2"

  storage_os_disk {
    name              = "myOsDisk"
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
      key_data = "ssh-rsa AAAAB3Nz{snip}hwhqT9h"
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
