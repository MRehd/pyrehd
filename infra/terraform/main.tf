# DATA
data "http" "my_ip" {
  url = "http://ipv4.icanhazip.com"
}

# SUBSCRIPTION LEVEL RESOURCES
resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.proj}-${var.env}"
  location = var.location
}

# RESOURCES
module "managed_identity" {
  source   = "./modules/umid"
  env      = var.env
  location = var.location
  rg_name  = azurerm_resource_group.rg.name
  proj     = var.proj
}

module "network" {
  source         = "./modules/vnet"
  env            = var.env
  location       = var.location
  proj           = var.proj
  rg_name        = azurerm_resource_group.rg.name
  subnet_address = var.subnet_address
  ip_rules       = concat(["${chomp(data.http.my_ip.response_body)}"], var.ip_rules)
}

module "storage" {
  source            = "./modules/st"
  env               = var.env
  location          = var.location
  rg_name           = azurerm_resource_group.rg.name
  proj              = var.proj
  ip_rules          = concat([chomp(data.http.my_ip.response_body)], var.ip_rules)
  sub_ids           = [module.network.sub_id, module.network.sub_dbk_private_id, module.network.sub_dbk_public_id]
  umid_principal_id = module.managed_identity.umid_principal_id
}

module "event_hub" {
  source         = "./modules/evh"
  env            = var.env
  location       = var.location
  rg_name        = azurerm_resource_group.rg.name
  ip_rules       = concat([chomp(data.http.my_ip.response_body)], var.ip_rules)
  proj           = var.proj
  umid_id        = module.managed_identity.umid_id
  sub_id         = module.network.sub_id
  sub_private_id = module.network.sub_dbk_private_id
  sub_public_id  = module.network.sub_dbk_public_id
}

module "key_vault" {
  source            = "./modules/kv"
  env               = var.env
  location          = var.location
  proj              = var.proj
  rg_name           = azurerm_resource_group.rg.name
  umid_principal_id = module.managed_identity.umid_principal_id
  st_name           = module.storage.st_name
  stc_name          = module.storage.stc_name
  st_key            = module.storage.st_key
  subnet_ids        = [module.network.sub_id, module.network.sub_dbk_private_id, module.network.sub_dbk_public_id]
  ip_rules          = concat(["${chomp(data.http.my_ip.response_body)}/32"], var.ip_rules)
  evhns_conn_str    = module.event_hub.evhns_conn_str
}

module "databricks" {
  source                     = "./modules/dbk"
  env                        = var.env
  location                   = var.location
  st_name                    = module.storage.st_name
  stc_name                   = module.storage.stc_name
  umid_id                    = module.managed_identity.umid_id
  umid_principal_id          = module.managed_identity.umid_principal_id
  kv_id                      = module.key_vault.kv_id
  kv_uri                     = module.key_vault.kv_uri
  vnet_id                    = module.network.vnet_id
  sub_private_name           = module.network.sub_dbk_private_name
  sub_private_association_id = module.network.sub_dbk_private_association_id
  sub_public_name            = module.network.sub_dbk_public_name
  sub_public_association_id  = module.network.sub_dbk_public_association_id
  dependencies               = var.dependencies
  proj                       = var.proj
  rg_name                    = azurerm_resource_group.rg.name
  git_config                 = var.git_config
  ip_rules                   = concat([chomp(data.http.my_ip.response_body)], var.ip_rules)
}

module "ad" {
  source = "./modules/ad"
  env    = var.env
  kv_id  = module.key_vault.kv_id
}