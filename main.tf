terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.27.0"
    }
  }

  backend "azurerm" {
    resource_group_name   = "tf_rg"
    storage_account_name  = "storagetf"
    container_name        = "tfstate"
    key                   = "terraform-mssqlvm.tfstate"
  }
}

provider "azurerm" {
  features {}
}

# Resource Group about storage account
resource azurerm_resource_group mssqlvmrg {
  name     = var.rg_name
  location = var.location

  tags     = {
    Name = "${var.rg_name}",
    RG   = "${var.rg_name}"
  }
}

# The VNet
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.rprefix}-vnet"
  address_space       = ["${var.vnet_cidr}"]
  location            = var.location
  resource_group_name = azurerm_resource_group.mssqlvmrg.name
}

# The subnet
resource "azurerm_subnet" "subnet" {
  name                 = "${var.rprefix}-subnet"
  resource_group_name  = azurerm_resource_group.mssqlvmrg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["${var.subnet_cidr}"]
}

# The VM public IP
resource "azurerm_public_ip" "public-ip" {
  name                = "${var.rprefix}-public-ip"
  location            = var.location
  resource_group_name = azurerm_resource_group.mssqlvmrg.name
  allocation_method   = "Dynamic"
}

# The network security group
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.rprefix}-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.mssqlvmrg.name
}

# The RDP access
resource "azurerm_network_security_rule" "rdp" {
  name                        = "RDP_Access"
  resource_group_name         = azurerm_resource_group.mssqlvmrg.name
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = 3389
  source_address_prefix       = var.my_public_ip
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.nsg.name
}

# The MSSQL access
resource "azurerm_network_security_rule" "mssql" {
  name                        = "MSSQL_Access"
  resource_group_name         = azurerm_resource_group.mssqlvmrg.name
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = 1433
  source_address_prefix       = var.my_public_ip
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.nsg.name
}

# The VM interface
resource "azurerm_network_interface" "nic" {
  name                = "${var.rprefix}-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.mssqlvmrg.name

  ip_configuration {
    name                          = "${var.rprefix}-nic-ip"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public-ip.id
  }
}

# Network security association between the VM if and the network security group
resource "azurerm_network_interface_security_group_association" "nic-nsga" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
  # needed to destory
  depends_on = [
    azurerm_network_interface.nic, 
    azurerm_network_security_group.nsg
  ]
}

# The VM
resource "azurerm_windows_virtual_machine" "vm" {
  name                      = "${var.rprefix}-vm"
  location                  = var.location
  resource_group_name       = azurerm_resource_group.mssqlvmrg.name
  network_interface_ids     = [azurerm_network_interface.nic.id]
  size                      = var.vm_size
  computer_name             = var.vm_name
  admin_username            = var.vm_admin
  admin_password            = var.vm_admin_pwd
  timezone                  = var.vm_tz
  provision_vm_agent        = true
  
  source_image_reference {
    publisher = "MicrosoftSQLServer"
    offer     = var.sql_vm_image
    sku       = "Standard"
    version   = var.sql_vm_image_version
  }

  os_disk {
    name                 = "${var.rprefix}-osdisk"
    caching              = "ReadOnly"
    storage_account_type = var.hdd
  }

  additional_capabilities {
    ultra_ssd_enabled  = true
  }

}

# Additional VM disks
resource "azurerm_managed_disk" "dbdata" {
  name                 = "${var.rprefix}-disk-dbdata"
  location             = var.location
  resource_group_name  = azurerm_resource_group.mssqlvmrg.name
  storage_account_type = var.premiumssd
  create_option        = "Empty"
  disk_size_gb         = var.db_data_disk
}

resource "azurerm_managed_disk" "dblog" {
  name                 = "${var.rprefix}-disk-dblog"
  location             = var.location
  resource_group_name  = azurerm_resource_group.mssqlvmrg.name
  storage_account_type = var.premiumssd
  create_option        = "Empty"
  disk_size_gb         = var.db_log_disk
}


resource "azurerm_managed_disk" "tempdb" {
  name                 = "${var.rprefix}-disk-tempdb"
  location             = var.location
  resource_group_name  = azurerm_resource_group.mssqlvmrg.name
  storage_account_type = var.premiumssd
  create_option        = "Empty"
  disk_size_gb         = var.db_tempdb_data_disk
}


resource "azurerm_managed_disk" "tempdblog" {
  name                 = "${var.rprefix}-disk-tempdblog"
  location             = var.location
  resource_group_name  = azurerm_resource_group.mssqlvmrg.name
  storage_account_type = var.premiumssd
  create_option        = "Empty"
  disk_size_gb         = var.db_tempdb_log_disk
}

resource "azurerm_managed_disk" "dbbk" {
  name                 = "${var.rprefix}-disk-dbbk"
  location             = var.location
  resource_group_name  = azurerm_resource_group.mssqlvmrg.name
  storage_account_type = var.premiumssd
  create_option        = "Empty"
  disk_size_gb         = var.db_bk_disk
}

# Attach additional disks to the VM
resource "azurerm_virtual_machine_data_disk_attachment" "vm-dbdata" {
  managed_disk_id    = azurerm_managed_disk.dbdata.id
  virtual_machine_id = azurerm_windows_virtual_machine.vm.id
  lun                = "0"
  caching            = "None"
}

resource "azurerm_virtual_machine_data_disk_attachment" "vm-dblog" {
  managed_disk_id    = azurerm_managed_disk.dblog.id
  virtual_machine_id = azurerm_windows_virtual_machine.vm.id
  lun                = "1"
  caching            = "None"
}

resource "azurerm_virtual_machine_data_disk_attachment" "vm-tempdb" {
  managed_disk_id    = azurerm_managed_disk.tempdb.id
  virtual_machine_id = azurerm_windows_virtual_machine.vm.id
  lun                = "2"
  caching            = "None"
}

resource "azurerm_virtual_machine_data_disk_attachment" "vm-tempdblog" {
  managed_disk_id    = azurerm_managed_disk.tempdblog.id
  virtual_machine_id = azurerm_windows_virtual_machine.vm.id
  lun                = "3"
  caching            = "None"
}

resource "azurerm_virtual_machine_data_disk_attachment" "vm-dbbk" {
  managed_disk_id    = azurerm_managed_disk.dbbk.id
  virtual_machine_id = azurerm_windows_virtual_machine.vm.id
  lun                = "4"
  caching            = "None"
}


# The SQL Server
resource "azurerm_mssql_virtual_machine" "mssql" {
  virtual_machine_id               = azurerm_windows_virtual_machine.vm.id
  sql_license_type                 = "PAYG"
  r_services_enabled               = true
  sql_connectivity_port            = 1433
  sql_connectivity_type            = "PRIVATE"
  sql_connectivity_update_password = var.mssql_sysadmin_pwd
  sql_connectivity_update_username = var.mssql_sysadmin
}
