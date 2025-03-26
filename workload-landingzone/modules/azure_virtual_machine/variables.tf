variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}

variable "location" {
  description = "The Azure region where the resources will be created."
  type        = string
}

variable "ip_configuration_name" {
  description = "(Required) A name used for this IP Configuration."
  type        = string
  default     = "internal"
}

variable "private_ip_address_allocation" {
  description = "(Required) The allocation method used for the Private IP Address. Possible values are Dynamic and Static."
  type        = string
  default     = "Dynamic"
}
variable "subnet_id" {
  description = "(Optional) The ID of the Subnet where this Network Interface should be located in."
  type        = string
}

variable "network_interface_name" {
  description = "The name of the network interface."
  type        = string
}

variable "vm_public_ip_name" {
  description = "The name of the public IP."
  type        = string
}

variable "allocation_method" {
  description = "(Required) Defines the allocation method for this IP address. Possible values are Static or Dynamic."
  type        = string
  default     = "Dynamic"
}

variable "ip_sku" {
  description = "(Optional) The SKU of the Public IP. Accepted values are Basic and Standard. Defaults to Standard. Changing this forces a new resource to be created."
  type        = string
  default     = "Basic"
}

variable "vm_name" {
  description = "The name of the Windows 10 virtual machine."
  type        = string
}

variable "vm_size" {
  description = "The size of the virtual machine (e.g., Standard_D2s_v3)."
  type        = string
}

variable "admin_username" {
  description = "The admin username for the virtual machine."
  type        = string
}

variable "admin_password" {
  description = "The admin password for the virtual machine."
  type        = string
}

variable "caching" {
  description = "(Required) The Type of Caching which should be used for the Internal OS Disk. Possible values are None, ReadOnly and ReadWrite."
  type        = string
  default     = "ReadWrite"
}

variable "storage_account_type" {
  description = " (Required) The Type of Storage Account which should back this the Internal OS Disk. Possible values are Standard_LRS, StandardSSD_LRS, Premium_LRS, StandardSSD_ZRS and Premium_ZRS. Changing this forces a new resource to be created."
  type        = string
  default     = "Premium_LRS"
}

variable "publisher" {
  description = "(Required) Specifies the publisher of the image used to create the virtual machines. Changing this forces a new resource to be created."
  type        = string
  default     = "microsoftwindowsdesktop"
}

variable "offer" {
  description = "(Required) Specifies the offer of the image used to create the virtual machines. Changing this forces a new resource to be created."
  type        = string
  default     = "Windows-10"
}

variable "sku" {
  description = "(Required) Specifies the SKU of the image used to create the virtual machines. Changing this forces a new resource to be created."
  type        = string
  default     = "win10-22h2-pro-g2"  
}

variable "image_version" {
  description = "(Required) Specifies the version of the image used to create the virtual machines. Changing this forces a new resource to be created."
  type        = string
  default     = "latest"
}

variable "tags" {
  description = "A mapping of tags to assign to the resources."
  type        = map(string)
  default     = {}
}