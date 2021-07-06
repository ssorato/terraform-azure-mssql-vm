variable "location" {
  description = "The Azure location where all resources in this example should be created."
  default     = "eastus"
}

variable "my_public_ip" {
  description = "My public ip used to enable firewall access."
}

variable "subscription_id" {
  description = "The Azure Subscription ID."
}

variable "tenant_id" {
  description = "The Azure Tenant ID."
}

variable "rg_name" {
  description = "The Resource Group name used in this deploy"
}

variable "rprefix" {
  description = "The resource name prefix"
  default     = "mssqlvm"
}

variable "sql_vm_image" {
  description = "The offered VM images available in the Azure Marketplace published by MicrosoftSQLServer"
}

variable "sql_vm_image_version" {
  description = "The offered VM images version available in the Azure Marketplace published by MicrosoftSQLServer"
}

variable "vm_size" {
  description = "The size of VM"
}

variable "vnet_cidr" {
  description = "The VNet CIDR"
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "The subnet CIDR"
  default     = "10.0.0.0/24"
}

variable "vm_name" {
  description = "The VM name"
}

variable "vm_admin" {
  description = "The VM administrator user"
  default     = "azadmin"
}

variable "vm_admin_pwd" {
  description = "The VM administrator password"
}

variable "vm_tz" {
  description = "The VM Time Zone"
  default     = "E. South America Standard Time"
}

variable "mssql_sysadmin" {
  description = "The SQL Server sysadmin login to create"
  default     = "azsa"
}

variable "mssql_sysadmin_pwd" {
  description = "The SQL Server sysadmin login password."
}

variable "db_data_disk" {
  description = "The size GB about SQL Server data disk."
  default     = 10
}

variable "db_log_disk" {
  description = "The size GB about SQL Server log disk."
  default     = 5
}

variable "db_tempdb_data_disk" {
  description = "The size GB about SQL Server tempdb data disk."
  default     = 2
}

variable "db_tempdb_log_disk" {
  description = "The size GB about SQL Server tempdb log disk."
  default     = 2
}

variable "db_bk_disk" {
  description = "The size GB about SQL Server backup disk."
  default     = 10
}

variable "hdd" {
  description = "The disk hdd type."
  default     = "Standard_LRS"
}

variable "ssd" {
  description = "The disk ssd type."
  default     = "StandardSSD_LRS"
}

variable "premiumssd" {
  description = "The disk premium ssd type."
  default     = "Premium_LRS"
}


