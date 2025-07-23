locals {
  azure_regions = [
    "westus2",
    "canadacentral"
  ]
  # endpoints = toset(["blob", "queue", "table", "file"])
  endpoint_zones = {
    blob = {
      domain_name         = "privatelink.blob.core.windows.net"
      resource_group_name = azurerm_resource_group.example.name
      virtual_network_links = {
        example = {
          vnetlinkname = "privatelink.blob.core.windows.net-link"
          vnetid       = azurerm_virtual_network.example.id
        }
      }
    },
    file = {
      domain_name         = "privatelink.file.core.windows.net"
      resource_group_name = azurerm_resource_group.example.name
      virtual_network_links = {
        example = {
          vnetlinkname = "privatelink.file.core.windows.net-link"
          vnetid       = azurerm_virtual_network.example.id
        }
      }
    }
    queue = {
      domain_name         = "privatelink.queue.core.windows.net"
      resource_group_name = azurerm_resource_group.example.name
      virtual_network_links = {
        example = {
          vnetlinkname = "privatelink.queue.core.windows.net-link"
          vnetid       = azurerm_virtual_network.example.id
        }
      }
    },
    table = {
      domain_name         = "privatelink.table.core.windows.net"
      resource_group_name = azurerm_resource_group.example.name
      virtual_network_links = {
        example = {
          vnetlinkname = "privatelink.table.core.windows.net-link"
          vnetid       = azurerm_virtual_network.example.id
        }
      }
    }
  }
}
