variable "ARM_CLIENT_ID" {
  type = string
  default = ""
}
variable "ARM_CLIENT_SECRET" {
  type = string
  default = ""
}
variable "ARM_SUBSCRIPTION_ID" {
  type = string
  default = ""
}
variable "ARM_TENANT_ID" {
  type = string
  default = ""
}

####

variable "resource_group_location" {
  default = "francecentral"
}