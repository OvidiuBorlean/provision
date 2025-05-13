variable "resource_group" {
}

variable "location" {
}

variable "subnet" {
}

resource "azurerm_public_ip" "public_ip" {
  name                = "public_ip"
  resource_group_name = var.resource_group
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"

}

resource "azurerm_network_interface" "main" {
  name                = "conectel-nic"
  location            = var.location
  resource_group_name = var.resource_group

  ip_configuration {
    name                          = "ipconfiguration"
    subnet_id                     = var.subnet
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

resource "random_string" "password" {
  length           = 12
  special          = true
  numeric          = true

}

resource "azurerm_virtual_machine" "conectelhost" {
  name                  = "conecthub"
  location              = var.location
  resource_group_name   = var.resource_group
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size               = "Standard_DS1_v2"

  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  connection {
        host = azurerm_public_ip.public_ip.ip_address
        user = "conectel_admin"
        type = "ssh"
        password = random_string.password.result
        timeout = "2m"
        agent = false
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }
  storage_os_disk {
    name              = "host"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "conectelhub"
    admin_username = "conectel_admin"
    admin_password = random_string.password.result
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "conectel"
  }

   provisioner "remote-exec" {
        inline = [
          "echo ovidiu > /tmp/ovidiu.txt",
          "curl -o bastion.sh https://raw.githubusercontent.com/OvidiuBorlean/provision/main/bastion.sh ",
          " chmod +x ./bastion.sh",
          "./bastion.sh"
        ]
    }
}
