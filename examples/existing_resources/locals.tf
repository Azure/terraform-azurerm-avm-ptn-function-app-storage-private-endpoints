locals {
  azure_regions = [
    "eastus",
    "westeurope",
    "eastasia",
    "japaneast"
  ]
  endpoints = toset(["blob", "queue", "table", "file"])
}