# // 3
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.27.0"
    }
  }
  backend "azurerm" {
      resource_group_name  = "terraform"
      storage_account_name = "conectel"
      container_name       = "tfstate"
      key                  = "terraform.tfstate"
  }

}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  resource_provider_registrations = "none" # This is only required when the User, Service Principal, or Identity running Terraform lacks the permissions to register Azure Resource Providers.
  subscription_id = "d53beca8-7450-4196-a689-84cf17f3bfe3"
  features {}
}


variable "resource-group" {
  type = string
  default = "conectel"
}

variable "location" {
  type = string
  default = "West Europe"
}

variable "vnet" {
  type = string
  default = "vnet"
}

variable "vm_subnet" {
  type = string
  default = "vm_subnet"
}

# Create a resource group
resource "azurerm_resource_group" "conectel" {
  name     = var.resource-group
  location = "West Europe"
}


resource "azurerm_virtual_network" "vnet" {
  name = var.vnet
  location = var.location
  resource_group_name = azurerm_resource_group.conectel.name
  address_space       = ["10.10.0.0/16"]
  dns_servers         = ["168.63.129.16"]
}

resource "azurerm_subnet" "subnet" {
  name = var.vm_subnet
  address_prefixes = ["10.10.12.0/24"]
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name = azurerm_resource_group.conectel.name

}


resource "azurerm_network_security_group" "nsg" {
  name                = "nsg"
  location            = azurerm_resource_group.conectel.location
  resource_group_name = azurerm_resource_group.conectel.name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 700
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "10.10.0.0/16"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsgconect" {
  subnet_id = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
  depends_on = [azurerm_network_security_group.nsg, azurerm_subnet.subnet, azurerm_virtual_network.vnet]
}

module "vms" {
  source = "./modules"
  resource_group = azurerm_resource_group.conectel.name
  location = var.location
  subnet = azurerm_subnet.subnet.id
}

output "resource_group" {
  value = azurerm_resource_group.conectel.name
}

output "subnet" {
  value = azurerm_subnet.subnet.id
}

output "admin_password" {
  value = module.vms.admin_password
}

output "ipaddress" {
  value = module.vms.ipaddress
