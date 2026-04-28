provider "azurerm" {
  features {}
}

provider "aws" {
  region = var.aws_region
}

resource "azurerm_resource_group" "data" {
  name     = "rg-${var.project_name}-foundation-${var.environment}"
  location = var.location
}

# --- Data Landing Zone (Storage) ---

resource "azurerm_storage_account" "lake" {
  name                     = "st${var.project_name}${var.environment}"
  resource_group_name      = azurerm_resource_group.data.name
  location                 = azurerm_resource_group.data.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true # Data Lake Gen2
}

# --- Platform Control Plane (AKS) ---

resource "azurerm_kubernetes_cluster" "data_k8s" {
  name                = "aks-data-governance-${var.environment}"
  location            = azurerm_resource_group.data.location
  resource_group_name = azurerm_resource_group.data.name
  dns_prefix          = "data-k8s"

  default_node_pool {
    name       = "default"
    node_count = 3
    vm_size    = "Standard_D2s_v3"
  }

  identity {
    type = "SystemAssigned"
  }
}

# --- Institutional Metadata Store (Postgres) ---

resource "azurerm_postgresql_flexible_server" "data" {
  name                   = "psql-data-metadata-${var.environment}"
  resource_group_name    = azurerm_resource_group.data.name
  location               = azurerm_resource_group.data.location
  version                = "13"
  administrator_login    = "dataadmin"
  administrator_password = var.db_password
  storage_mb             = 32768
  sku_name               = "GP_Standard_D2ds_v4"
}

# --- Secure Key Vault ---

resource "azurerm_key_vault" "vault" {
  name                        = "kv-data-${var.environment}"
  location                    = azurerm_resource_group.data.location
  resource_group_name         = azurerm_resource_group.data.name
  enabled_for_disk_encryption = true
  tenant_id                   = var.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"
}

# --- External Data Sink (AWS S3) ---

resource "aws_s3_bucket" "external_lake" {
  bucket = "db-data-external-lake-${var.environment}"
}
