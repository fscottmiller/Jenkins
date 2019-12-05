provider "azurerm" {
    client_id = "88c469f8-463b-4b30-b2e5-49ec17b53aa8"
    client_secret = "4C4-yniNXg:KKr?hu-c2LOxFZ3wPVHoH"
    tenant_id = "28e5a145-70c6-44e3-ba17-7b09d54fe531"
    subscription_id = "8287bf47-261a-49f1-974d-75f52c339161"
}

variable "prefix" {
  default = "build-containers"
}

resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-resources"
  location = "East US 2"
  tags = {"ProjectCode" = 50104}
}

data "azurerm_subnet" "main" {
    name = "mna-use2-nonProd-dev-app"
    virtual_network_name = "mna-use2-nonProd-vnet-dev-001"
    resource_group_name = "mna-use2-nonprod-rg"
}

resource "azurerm_public_ip" "main" {
  name                = "dvo-pip"
  location            = "East US 2"
  resource_group_name = "${azurerm_resource_group.main.name}"
  allocation_method   = "Static"

  tags = {
    ProjectCode = 50104
  }
}

resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = "${data.azurerm_subnet.main.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = "${azurerm_public_ip.main.id}"
  }
}

resource "azurerm_virtual_machine" "main" {
  name                  = "${var.prefix}-vm"
  location              = "${azurerm_resource_group.main.location}"
  resource_group_name   = "${azurerm_resource_group.main.name}"
  network_interface_ids = ["${azurerm_network_interface.main.id}"]
  vm_size               = "Standard_D4s_v3"
  

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true


  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {"ProjectCode" = 50104}
}