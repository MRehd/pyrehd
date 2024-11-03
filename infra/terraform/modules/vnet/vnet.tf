# VARIABLES --------------------------------------------------------------------------------------------------------------------------
variable "env" {
  type = string
}
variable "rg_name" {
  type = string
}
variable "location" {
  type = string
}
variable "proj" {
  type = string
}
variable "subnet_address" {
  type = list(string)
}
variable "ip_rules" {
  type = list(string)
}

# RESOURCES --------------------------------------------------------------------------------------------------------------------------
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-${var.proj}-${var.env}"
  location            = var.location
  resource_group_name = var.rg_name

  security_rule {
    name                       = "AllowMyIP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefixes    = var.ip_rules
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "nsg_dbk" {
  name                = "nsg-dbk-${var.env}"
  location            = var.location
  resource_group_name = var.rg_name

  security_rule {
    name                       = "Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-worker-inbound"
    description                = "Required for worker nodes communication within a cluster."
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
    access                     = "Allow"
    priority                   = 100
    direction                  = "Inbound"
  }

  security_rule {
    name                       = "Microsoft.Databricks-workspaces_UseOnly_databricks-control-plane-to-worker-ssh"
    description                = "Required for Databricks control plane management of worker nodes."
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "AzureDatabricks"
    destination_address_prefix = "VirtualNetwork"
    access                     = "Allow"
    priority                   = 101
    direction                  = "Inbound"
  }

  security_rule {
    name                       = "Microsoft.Databricks-workspaces_UseOnly_databricks-control-plane-to-worker-proxy"
    description                = "Required for Databricks control plane communication with worker nodes."
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5557"
    source_address_prefix      = "AzureDatabricks"
    destination_address_prefix = "VirtualNetwork"
    access                     = "Allow"
    priority                   = 102
    direction                  = "Inbound"
  }

  security_rule {
    name                       = "Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-worker-outbound"
    description                = "Required for worker nodes communication within a cluster."
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
    access                     = "Allow"
    priority                   = 100
    direction                  = "Outbound"
  }

  security_rule {
    name                       = "Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-databricks-webapp"
    description                = "Required for workers communication with Databricks Webapp."
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "AzureDatabricks"
    access                     = "Allow"
    priority                   = 101
    direction                  = "Outbound"
  }

  security_rule {
    name                       = "Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-sql"
    description                = "Required for workers communication with Azure SQL services."
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3306"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "Sql"
    access                     = "Allow"
    priority                   = 102
    direction                  = "Outbound"
  }

  security_rule {
    name                       = "Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-storage"
    description                = "Required for workers communication with Azure Storage services."
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "Storage"
    access                     = "Allow"
    priority                   = 103
    direction                  = "Outbound"
  }

  security_rule {
    name                       = "Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-eventhub"
    description                = "Required for worker communication with Azure Eventhub services."
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9093"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "EventHub"
    access                     = "Allow"
    priority                   = 104
    direction                  = "Outbound"
  }

  security_rule {
    name                       = "Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-adf"
    description                = "Required for workers communication with ADF."
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "AzureDatabricks"
    destination_address_prefix = "DataFactory"
    access                     = "Allow"
    priority                   = 105
    direction                  = "Outbound"
  }

  security_rule {
    name                       = "Microsoft.Databricks-workspaces_UseOnly_adf-to-databricks-worker"
    description                = "Required for workers communication with ADF."
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "DataFactory"
    destination_address_prefix = "AzureDatabricks"
    access                     = "Allow"
    priority                   = 106
    direction                  = "Inbound"
  }

  security_rule {
    name                       = "AllowVnetInBound"
    description                = "Allow inbound traffic from all VMs in VNET"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
    access                     = "Allow"
    priority                   = 800
    direction                  = "Inbound"
  }

  security_rule {
    name                       = "AllowAzureLoadBalancerInBound"
    description                = "Allow inbound traffic from azure load balancer"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
    access                     = "Allow"
    priority                   = 801
    direction                  = "Inbound"
  }

  security_rule {
    name                       = "DenyAllInBound"
    description                = "Deny all inbound traffic"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    access                     = "Deny"
    priority                   = 900
    direction                  = "Inbound"
  }

  security_rule {
    name                       = "AllowVnetOutBound"
    description                = "Allow outbound traffic from all VMs to all VMs in VNET"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
    access                     = "Allow"
    priority                   = 800
    direction                  = "Outbound"
  }

  security_rule {
    name                       = "AllowInternetOutBound"
    description                = "Allow outbound traffic from all VMs to Internet"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "Internet"
    access                     = "Allow"
    priority                   = 801
    direction                  = "Outbound"
  }

  security_rule {
    name                       = "DenyAllOutBound"
    description                = "Deny all outbound traffic"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    access                     = "Deny"
    priority                   = 900
    direction                  = "Outbound"
  }
}

# VNET ----------------------------------------------------------------------------------------------
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.proj}-${var.env}"
  location            = var.location
  resource_group_name = var.rg_name
  address_space       = var.subnet_address
}

# PROJ SUBNET ---------------------------------------------------------------------------------------
resource "azurerm_subnet" "sub" {
  name                 = "sub-${var.proj}-${var.env}"
  resource_group_name  = azurerm_virtual_network.vnet.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_address[0]]
  service_endpoints    = ["Microsoft.Storage", "Microsoft.EventHub", "Microsoft.KeyVault"]
}

resource "azurerm_subnet_network_security_group_association" "sub_association" {
  subnet_id                 = azurerm_subnet.sub.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_subnet" "sub_dbk_private" {
  name                 = "sub-private-${var.env}"
  resource_group_name  = azurerm_virtual_network.vnet.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_address[1]]
  delegation {
    name = "delegation"

    service_delegation {
      name = "Microsoft.Databricks/workspaces"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
        "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"
      ]
    }
  }
  service_endpoints = ["Microsoft.Storage", "Microsoft.EventHub", "Microsoft.KeyVault"]
}

resource "azurerm_subnet_network_security_group_association" "sub_dbk_private_association" {
  subnet_id                 = azurerm_subnet.sub_dbk_private.id
  network_security_group_id = azurerm_network_security_group.nsg_dbk.id
}

resource "azurerm_subnet" "sub_dbk_public" {
  name                 = "sub-public-${var.env}"
  resource_group_name  = azurerm_virtual_network.vnet.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_address[2]]
  delegation {
    name = "delegation"

    service_delegation {
      name = "Microsoft.Databricks/workspaces"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
        "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"
      ]
    }
  }
  service_endpoints = ["Microsoft.Storage", "Microsoft.EventHub", "Microsoft.KeyVault"]
}

resource "azurerm_subnet_network_security_group_association" "sub_dbk_public_association" {
  subnet_id                 = azurerm_subnet.sub_dbk_public.id
  network_security_group_id = azurerm_network_security_group.nsg_dbk.id
}