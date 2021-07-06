# Create a SQL Server on Azure VM

Create a _SQL Server on Azure VM_ on Azure and store the Terraform state on Azure storage account

Requires a _terraform.tfvars_

```tf
location             = "eastus"
my_public_ip         = "xxx.xxx.xxx.xxx"
subscription_id      = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
tenant_id            = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
rg_name              = "mssqlRG"
vnet_cidr            = "10.0.0.0/16"
subnet_cidr          = "10.0.0.0/24"
rprefix              = "mssqlvm"
vm_name              = "TFMSSQLVM01"
sql_vm_image         = "SQL2008R2SP3-WS2008R2SP1"
sql_vm_image_version = "10.72.200310"
# az vm list-sizes --location "eastus"
#vm_size              = "Standard_B4ms"
vm_size              = "Standard_D4s_v3"
vm_admin             = "azureadm"
vm_admin_pwd         = "xxxxxxxxxxxxxxx"
mssql_sysadmin       = "azureadm"
mssql_sysadmin_pwd   = "xxxxxxxxxxxxxxx"
db_data_disk         = 250
db_log_disk          = 10
db_tempdb_data_disk  = 20
db_tempdb_log_disk   = 10
db_bk_disk           = 550
```

The default _location_ is `eastu` and the firewall grant access to the _my\_public\_ip_

You can list the offered images published by MicrosoftSQLServer using az cli

```bash
$ az vm image list -l eastus -p MicrosoftSQLServer --all
```

List offered SKU about SQL Server 2008R2SP3 on Windows 2008R2SP1

```bash
$ az vm image list-skus -l eastus -p MicrosoftSQLServer -f SQL2008R2SP3-WS2008R2SP1
```
