resource "azurerm_resource_group" "kiratech" {
  name     = "kiratech-test"
  location = var.resource_group_location
}

resource "azurerm_network_security_group" "kiratech" {
  name                = "nsg-kiratech"
  location            = azurerm_resource_group.kiratech.location
  resource_group_name = azurerm_resource_group.kiratech.name

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

resource "azurerm_virtual_network" "kiratech" {
  name                = "network-kiratech"
  location            = azurerm_resource_group.kiratech.location
  resource_group_name = azurerm_resource_group.kiratech.name
  address_space       = ["172.0.0.0/24"]

  tags = {
    environment = "kiratech"
  }
}

resource "azurerm_subnet" "kiratech" {
  name                 = "sub-kiratech"
  resource_group_name  = azurerm_resource_group.kiratech.name
  virtual_network_name = azurerm_virtual_network.kiratech.name
  address_prefixes     = ["172.0.0.128/25"]
}

resource "azurerm_subnet_network_security_group_association" "kiratech" {
  subnet_id                 = azurerm_subnet.kiratech.id
  network_security_group_id = azurerm_network_security_group.kiratech.id
}

resource "random_string" "master" {
  length  = 2
  special = false
  upper   = false
}

output "random_result_master" {
    value = random_string.master.result
}

resource "azurerm_public_ip" "public_ip" {
  name                = "PIP"
  resource_group_name = azurerm_resource_group.kiratech.name
  location            = azurerm_resource_group.kiratech.location
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "kiratech" {
  name                = "nic-${random_string.master.result}"
  location            = azurerm_resource_group.kiratech.location
  resource_group_name = azurerm_resource_group.kiratech.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.kiratech.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

resource "azurerm_linux_virtual_machine" "kiratech" {
  name                = "master-${random_string.master.result}"
  resource_group_name = azurerm_resource_group.kiratech.name
  location            = azurerm_resource_group.kiratech.location
  size                = "Standard_B2s"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.kiratech.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("./id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    offer      = "0001-com-ubuntu-server-focal"
    publisher  = "Canonical"
    sku        = "20_04-lts-gen2"
    version    = "latest"
  }
}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "master" {
  virtual_machine_id = azurerm_linux_virtual_machine.kiratech.id
  location           = azurerm_resource_group.kiratech.location
  enabled            = true

  daily_recurrence_time = "2000"
  timezone              = "W. Europe Standard Time"


  notification_settings {
    enabled         = false
  }
 }