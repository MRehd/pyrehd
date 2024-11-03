# INPUT VARIABLES
variable "env" {
  type    = string
  default = "dev"
}

variable "location" {
  type    = string
  default = "northeurope"
}

variable "proj" {
  type    = string
  default = "rehd"
}

variable "ip_rules" {
  type    = list(string)
  default = []
}

variable "subnet_address" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "dependencies" {
  type = list(string)
  default = [
    "neuralprophet",
    "typing-extensions==4.8.0",
    "azure-eventhub"
  ]
}

variable "git_config" {
  type = object({
    url             = string
    git_provider    = string
    branch          = string
    path            = string
    sparse_checkout = list(string)
  })
  default = {
    url             = "https://dev.azure.com/pyrehd/_git/rehd"
    git_provider    = "azureDevOpsServices"
    branch          = "dev"
    path            = "/Shared/rehd"
    sparse_checkout = ["dbk"]
  }
}
