# Creation du reseau
resource "azurerm_virtual_network" "vnet" {
  name                = "virtualNetwork-demo2"
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

resource "azurerm_public_ip" "public_ip" {
  count                        = "${var.nbr}"
  name                         = "terraform-demo2-${count.index + 1}"
  location                     = "eastus"
  resource_group_name          = "${var.rg}"
  public_ip_address_allocation = "static"

  tags {
    environment = "terraform-demo"
  }
}

resource "azurerm_network_interface" "network_interface" {
  count               = "${var.nbr}"
  name                = "terraform-demo2-${count.index +1}"
  location            = "eastus"
  resource_group_name = "${var.rg}"

  ip_configuration {
    name                          = "terraform-demo2-${count.index + 1}"
    subnet_id                     = "${azurerm_subnet.subnet1.id}"
    private_ip_address_allocation = "dynamic"

    # public_ip_address_id          = "${azurerm_public_ip.public_ip.*.id}"
    public_ip_address_id = "${element(azurerm_public_ip.public_ip.*.id, count.index)}"
  }

  tags {
    environment = "terraform-demo"
  }
}
