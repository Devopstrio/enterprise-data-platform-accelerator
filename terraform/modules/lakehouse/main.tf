# EDPA: High-Performance Lakehouse Module
# Architecture: ADLS Gen2 with Private Link & Medallion Structure

resource "azurerm_storage_account" "lake" {
  name                     = "stdevopstrioedpaprod"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "GRS" # Geo-Redundant for AI Reliability
  account_kind             = "StorageV2"
  is_hns_enabled           = true # Data Lake Gen2 enabled

  # Security Hardening
  public_network_access_enabled = false
  infrastructure_encryption_enabled = true
}

# Medallion Architecture Containers
resource "azurerm_storage_data_lake_gen2_filesystem" "bronze" {
  name               = "bronze-raw"
  storage_account_id = azurerm_storage_account.lake.id
}

resource "azurerm_storage_data_lake_gen2_filesystem" "silver" {
  name               = "silver-unified"
  storage_account_id = azurerm_storage_account.lake.id
}

resource "azurerm_storage_data_lake_gen2_filesystem" "gold" {
  name               = "gold-optimized"
  storage_account_id = azurerm_storage_account.lake.id
}

# Ingestion Subsystem: Event Hubs for Streaming
resource "azurerm_eventhub_namespace" "stream" {
  name                = "evh-devopstrio-streaming"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  capacity            = 2
}

output "lakehouse_id" {
  value = azurerm_storage_account.lake.id
}
