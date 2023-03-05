resource "random_string" "aworker" {
  length  = 4
  special = false
  upper   = false
}

output "random_result_aworker" {
    value = random_string.aworker.result
}

resource "azurerm_network_interface" "kiratech" {
  name                = "nic-${random_string.aworker.result}"
  location            = var.rsg_location
  resource_group_name = var.rsg_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_name
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "kiratech" {
  name                = "aworker-${random_string.aworker.result}"
  resource_group_name = var.rsg_name
  location            = var.rsg_location
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

resource "azurerm_dev_test_global_vm_shutdown_schedule" "worker" {
  virtual_machine_id = azurerm_linux_virtual_machine.kiratech.id
  location           = var.rsg_location
  enabled            = true

  daily_recurrence_time = "2000"
  timezone              = "W. Europe Standard Time"


  notification_settings {
    enabled         = false
  }
 }