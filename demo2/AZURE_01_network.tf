data "azurerm_subnet" "subnet" {
  name                 = "default"
  virtual_network_name = "fmedery-poc-vnet"
  resource_group_name  = "${var.rg}"
}

resource "azurerm_public_ip" "public_ip" {
  count                        = "${var.nbr}"
  name                         = "terraform-demo${count.index + 1}"
  location                     = "eastus"
  resource_group_name          = "${var.rg}"
  public_ip_address_allocation = "dynamic"

  tags {
    environment = "terraform-demo"
  }
}

resource "azurerm_network_interface" "network_interface" {
  count               = "${var.nbr}"
  name                = "terraform-demo${count.index +1}"
  location            = "eastus"
  resource_group_name = "${var.rg}"

  ip_configuration {
    name                          = "terraform-demo${count.index + 1}"
    subnet_id                     = "${data.azurerm_subnet.subnet.id}"
    private_ip_address_allocation = "dynamic"

    # public_ip_address_id          = "${azurerm_public_ip.public_ip.*.id}"
    public_ip_address_id = "${element(azurerm_public_ip.public_ip.*.id, count.index)}"
  }

  tags {
    environment = "terraform-demo"
  }
}
