terraform {

  required_version = ">=0.12"

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = ""
  client_id       = ""
  client_secret   = ""
  tenant_id       = ""

}
locals {
  custom_data = <<CUSTOM_DATA
  #!/bin/bash
  curl -o bastion.sh https://raw.githubusercontent.com/OvidiuBorlean/provision/main/bastion.sh && chmod +x ./bastion.sh && ./bastion.sh
  CUSTOM_DATA
  }

# Encode and pass you script
#variable "custom_data" {
#       default = base64encode(local.custom_data)
#}

variable "resource_group_name_prefix" {
  default       = "bastion"
  description   = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}

variable "resource_group_location" {
  default       = "westeurope"
  description   = "Location of the resource group."
}

resource "random_pet" "rg-name" {
  prefix    = var.resource_group_name_prefix
}

resource "azurerm_resource_group" "rg" {
  name      = random_pet.rg-name.id
  location  = var.resource_group_location
}

# Create virtual network
resource "azurerm_virtual_network" "bastion_vnet" {
  name                = "bastionnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create subnet
resource "azurerm_subnet" "bastion_vnet_subnet" {
  name                 = "bastionsubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.bastion_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "bastionPublicIP" {
  name                = "bastionPublicIp"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}
# Create Network Security Group and rule
resource "azurerm_network_security_group" "bastionnsg" {
  name                = "bastionNSG"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

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
}
# Create network interface
resource "azurerm_network_interface" "mybastionnic" {
  name                = "myBastionNIC"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "myNicConfiguration"
    subnet_id                     = azurerm_subnet.bastion_vnet_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.bastionPublicIP.id
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.mybastionnic.id
  network_security_group_id = azurerm_network_security_group.bastionnsg.id
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = azurerm_resource_group.rg.name
  }

  byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "mystorageaccount" {
  name                     = "diag${random_id.randomId.hex}"
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Create (and display) an SSH key
resource "tls_private_key" "example_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
# Create virtual machine
resource "azurerm_linux_virtual_machine" "bastion" {
  name                  = "myBastion"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.mybastionnic.id]
  size                  = "Standard_DS1_v2"

  os_disk {
    name                 = "myOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  computer_name                   = "bastion"
  admin_username                  = "azureuser"
  admin_password                  = ""
  disable_password_authentication = false

  user_data = base64encode("apt install nginx -y")

  connection {
        host = self.public_ip_address
        user = "azureuser"
        type = "ssh"
        password = "LAwpq7rstyo2ovi"
        timeout = "4m"
        agent = false
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
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
output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "public_ip_address" {
  value = azurerm_linux_virtual_machine.bastion.public_ip_address
}

output "tls_private_key" {
  value     = tls_private_key.example_ssh.private_key_pem
  sensitive = true
}
