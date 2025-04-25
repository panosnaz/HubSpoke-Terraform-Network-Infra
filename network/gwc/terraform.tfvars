# GWC Hub resources
conn_sub_id        = "<REDACTED>"
hub_resource_group = "rg-connectivity-gwc-net"

hub_location  = "germanywestcentral"
hub_vnet_name = "vnet-connectivity-gwc"
hub_vnet_cidr = "10.10.0.0/21"

gateway_subnet                 = "10.10.0.0/24"
firewall_subnet                = "10.10.1.0/24"
firewall_name                  = "fw-connectivity-gwc"
firewall_policy_name           = "fw-connectivity-gwc-policy"
firewall_pip_name              = "fw-connectivity-gwc-pip"
firewall_pip_allocation_method = "Static"
firewall_pip_sku               = "Standard"
firewall_sku_tier              = "Premium"
firewall_zones                 = ["1", "2", "3"]
bastion_subnet                 = "10.10.2.64/26"
bastion_host                   = "bastion-connectivity-gwc"
bastion_ip                     = "bastion-connectivity-gwc-pip"
conn_vnet_subnets = {
  subnet_1 = {
    name             = "snet-connectivity-gwc-devops"
    address_prefixes = "10.10.2.0/28"
    nsg_name         = "nsg-connectivity-gwc-devops"
    service_delegation = [
      {
        name    = "Microsoft.DevOpsInfrastructure/pools"
        actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      }
    ]
    service_endpoints                 = ["Microsoft.Storage"]
    private_endpoint_network_policies = "Enabled"
  },
  subnet_2 = {
    name                              = "snet-connectivity-gwc-storagePE"
    address_prefixes                  = "10.10.2.16/28"
    nsg_name                          = "nsg-connectivity-gwc-storagePE"
    service_delegation                = []
    service_endpoints                 = ["Microsoft.Storage"]
    private_endpoint_network_policies = "Disabled"
  }
}

# GWC HUB VPN Gateway
vpn_gateway_location                      = "germanywestcentral"
vpn_gateway_pip_name                      = "vgw-connectivity-gwc-pip"
vpn_gateway_name                          = "vgw-connectivity-gwc"
vpn_gateway_sku                           = "VpnGw3AZ"
vpn_gateway_type                          = "Vpn"
vpn_gateway_vpn_type                      = "RouteBased"
vpn_gateway_private_ip_address_allocation = "Dynamic"
hub_vpn_gateway1_pip_sku                  = "Standard"
hub_vpn_gateway1_pip_allocation_method    = "Static"
hub_vpn_gateway1_pip_zones                = ["1", "2", "3"]
vpn_gateway_udr_name                      = "rt-connectivity-gwc-vgw"
vpn_gateway_udr_routes = {

  route_01 = {
    name                   = "udr-prod-gwc"
    address_prefix         = "10.10.12.0/22"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.10.1.4"
  }
  route_02 = {
    name                   = "udr-identity-gwc"
    address_prefix         = "10.10.8.0/23"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.10.1.4"
  }
  route_03 = {
    name                   = "udr-dev-gwc"
    address_prefix         = "10.10.16.0/22"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.10.1.4"
  }
  route_04 = {
    name                   = "udr-mgmt-gwc"
    address_prefix         = "10.10.10.0/23"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.10.1.4"
  }
}

############################
# P2S VPN to GWC HUB
############################
vpn_client_address_space = ["10.10.252.0/22"]
# vpn_auth_types           = ["AAD"]
vpn_auth_types          = ["Certificate"]
root_certificate_name_1 = "rootCA"
public_cert_data_1      = <<EOF
<REDACTED>
EOF
root_certificate_name_2 = "SUBCA"
public_cert_data_2      = <<EOF
<REDACTED>
EOF

vpn_client_protocols = ["IkeV2", "OpenVPN"]
vpn_gateway_custom_route_address_prefixes = [
  "10.10.0.0/16"
]

############################
# S2S onprem VPN to GWC HUB
############################
local_network_gateway_name = "lgw-connectivity-gwc"
vpn_connection_name        = "vgw-connectivity-gwc-s2s-onpremises"
vpn_connection_type        = "IPsec"
local_network_gateway_pip  = "<REDACTED>"
local_network_address_space = [
  "192.168.1.0/25",
  "192.168.2.0/25",
  "192.168.3.0/24"
]

ipsec_shared_key = "<REDACTED>"

dh_group         = "DHGroup2"
ike_encryption   = "GCMAES256"
ike_integrity    = "SHA256"
ipsec_encryption = "GCMAES256"
ipsec_integrity  = "GCMAES256"
pfs_group        = "PFS2"
sa_lifetime      = "28800"


firewall_policy_rule_collection_groups = {
  "fw-policy-rcg" = {
    priority = 100
    # Network rules 
    firewall_network_rule_collections = {
      "Net-rules_identity-gwc-dc" = {
        action = "Allow"
        rules = [
          {
            name              = "Net-rules_identity-gwc-dc-kms-activation"
            source_addresses  = ["10.100.8.0/27"]
            destination_ports = ["1688"]
            destination_fqdns = ["azkms.core.windows.net"]
            protocols         = ["TCP"]
          },
          {
            name                  = "DCs-To-Monitor"
            source_addresses      = ["10.100.8.0/27"]
            destination_ports     = ["443"]
            destination_addresses = ["AzureMonitor", "Storage"]
            protocols             = ["TCP"]
          }
        ]
      },
      "OnPrem_VPN_access_to_HUB" = {
        action = "Allow"
        rules = [
          {
            name                  = "onprem_tcp_access_to_DC"
            source_addresses      = ["192.168.1.3/32", "192.168.1.4/32"]
            destination_ports     = ["49443", "464", "88", "3268", "3269", "636", "389", "137", "49152-65535", "135", "445", "5985", "53", "123", "138", "139", "3389"]
            destination_addresses = ["10.10.8.4/32", "10.10.8.5/32"]
            protocols             = ["TCP"]
          },
          {
            name                  = "onprem_udp_access_to_DC"
            source_addresses      = ["192.168.1.3/32", "192.168.1.4/32"]
            destination_ports     = ["464", "88", "389", "137", "135", "53", "123", "138", "139", "3389"]
            destination_addresses = ["10.10.8.4/32", "10.10.8.5/32"]
            protocols             = ["UDP"]
          },
          {
            name                  = "DC_tcp_access_to_onprem"
            source_addresses      = ["10.10.8.4/32", "10.10.8.5/32"]
            destination_ports     = ["49443", "464", "88", "3268", "3269", "636", "389", "137", "49152-65535", "135", "445", "5985", "53", "123", "138", "139", "3389"]
            destination_addresses = ["192.168.1.3/32", "192.168.1.4/32"]
            protocols             = ["TCP"]
          },
          {
            name                  = "DC_udp_access_to_onprem"
            source_addresses      = ["10.10.8.4/32", "10.10.8.5/32"]
            destination_ports     = ["464", "88", "389", "137", "135", "53", "123", "138", "139", "3389"]
            destination_addresses = ["192.168.1.3/32", "192.168.1.4/32"]
            protocols             = ["UDP"]
          }
        ]
      }
    }
    # App rules 
    firewall_app_rule_collections = {
      "Allow-Microsoft-Updates" = {
        action = "Allow"
        rules = [
          {
            name              = "Allow-MS-Updates_fqdns"
            source_addresses  = ["10.10.8.0/27", "10.10.8.160/27"]
            destination_fqdns = ["*.windowsupdate.microsoft.com", "*.update.microsoft.com", "*.windowsupdate.com", "*.download.windowsupdate.com", "*.ntservicepack.microsoft.com"]
            protocols = [{
              port = "443"
              type = "Https"
              },
              {
                port = "80"
                type = "Http"
            }]
          },
          {
            name                  = "Allow-MS-Updates_fqdnTags"
            source_addresses      = ["10.10.8.0/27", "10.10.8.160/27"]
            destination_fqdn_tags = ["WindowsUpdate"]
            protocols = [{
              port = "443"
              type = "Https"
              },
              {
                port = "80"
                type = "Http"
            }]
          }
        ]
      },
      "DevOps" = {
        action = "Allow"
        rules = [
          {
            name              = "DevOpsPoolComs"
            source_addresses  = ["10.100.10.128/28"]
            destination_fqdns = ["objects.githubusercontent.com", "graph.microsoft.com", "github.com", "releases.hashicorp.com", "registry.terraform.io", "management.azure.com", "login.microsoftonline.com", "*.prod.manageddevops.microsoft.com", "rmprodbuilds.azureedge.net", "vstsagentpackage.azureedge.net", "*.queue.core.windows.net", "server.pipe.aria.microsoft.com", "azure.archive.ubuntu.com", "www.microsoft.com", "packages.microsoft.com", "ppa.launchpad.net", "dl.fedoraproject.org", "auth.docker.io", "dev.azure.com", "*.services.visualstudio.com", "*.vsblob.visualstudio.com", "*.vssps.visualstudio.com", "*.visualstudio.com"]
            protocols = [{
              port = "443"
              type = "Https"
              },
              {
                port = "80"
                type = "Http"
            }]
          }
        ]
      }
    }
    # DNAT rules 
    firewall_dnat_rule_collections = {
      # "DNAT_rule_collection1" = {
      #   action = "Dnat"
      #   rules = [
      #     {
      #       description = "List of firewall DNAT rules"

      #       name                = "RDP_to_TestVMKeyVaultProd"
      #       source_addresses    = ["5.55.210.13/32"]
      #       destination_ports   = ["3389"]
      #       destination_address = "x.x.x.x" # AZ FW IP
      #       translated_port     = "3389"
      #       translated_address  = "10.10.13.5"
      #       protocols           = ["TCP"]
      #     }
      #   ]
      # }
    }
  }
}

# GWC PROD resources
prod_sub_id         = "<REDACTED>"
prod_resource_group = "rg-prod-gwc-net"
prod_vnet_name      = "vnet-prod-gwc"
prod_vnet_location  = "germanywestcentral"
prod_vnet_cidr      = "10.10.12.0/22"
prod_udr_name       = "rt-prod-gwc"

prod_vnet_subnets = {
  subnet_1 = {
    name                              = "snet-prod-gwc-app"
    address_prefixes                  = "10.10.12.0/25"
    nsg_name                          = "nsg-prod-gwc-app"
    service_delegation                = []
    service_endpoints                 = ["Microsoft.Storage"]
    private_endpoint_network_policies = "Enabled"
  },
  subnet_2 = {
    name                              = "snet-prod-gwc-db"
    address_prefixes                  = "10.10.12.128/25"
    nsg_name                          = "nsg-prod-gwc-db"
    service_delegation                = []
    service_endpoints                 = ["Microsoft.Storage"]
    private_endpoint_network_policies = "Enabled"
  }
  subnet_3 = {
    name                              = "snet-prod-gwc-keyvault"
    address_prefixes                  = "10.10.13.0/27"
    nsg_name                          = "nsg-prod-gwc-keyvault"
    service_delegation                = []
    service_endpoints                 = ["Microsoft.Storage"]
    private_endpoint_network_policies = "Disabled"
  }
}
prod_udr_routes = {
  route_01 = {
    name                   = "udr-prod-gwc"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.10.1.4"
  }
}

peer_remote_gw       = true
peer_gateway_transit = true

global_tags = {
  "BusinessCriticality" = "Critical"
  "BusinessUnit"        = "IT"
  "OperationsTeam"      = "ITOps"
  "Workload"            = "Network"
  "Environment"         = "Shared"
}


# GWC DEV resources
dev_sub_id               = "<REDACTED>"
dev_resource_group       = "rg-dev-gwc-net"
dev_vnet_name            = "vnet-dev-gwc"
dev_vnet_location        = "germanywestcentral"
dev_vnet_cidr            = "10.10.16.0/22"
dev_udr_name             = "rt-dev-gwc"
dev_peer_remote_gw       = true
dev_peer_gateway_transit = true

dev_vnet_subnets = {
  subnet_1 = {
    name                              = "snet-dev-gwc-app"
    address_prefixes                  = "10.10.16.0/25"
    nsg_name                          = "nsg-dev-gwc-app"
    service_delegation                = []
    service_endpoints                 = ["Microsoft.Storage"]
    private_endpoint_network_policies = "Enabled"
  },
  subnet_2 = {
    name                              = "snet-dev-gwc-db"
    address_prefixes                  = "10.10.16.128/25"
    nsg_name                          = "nsg-dev-gwc-db"
    service_delegation                = []
    service_endpoints                 = ["Microsoft.Storage"]
    private_endpoint_network_policies = "Enabled"
  }
}
dev_udr_routes = {
  route_01 = {
    name                   = "udr-dev-gwc"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.10.1.4"
  }
}

# GWC identity resources
identity_sub_id               = "<REDACTED>"
identity_resource_group       = "rg-identity-gwc-net"
identity_vnet_name            = "vnet-identity-gwc"
identity_vnet_location        = "germanywestcentral"
identity_vnet_cidr            = "10.10.8.0/23"
identity_udr_name             = "rt-identity-gwc"
identity_peer_remote_gw       = true
identity_peer_gateway_transit = true

identity_vnet_subnets = {
  subnet_1 = {
    name                              = "snet-identity-gwc-dc"
    address_prefixes                  = "10.10.8.0/27"
    nsg_name                          = "nsg-identity-gwc-dc"
    service_delegation                = []
    service_endpoints                 = ["Microsoft.Storage"]
    private_endpoint_network_policies = "Enabled"
  },
  subnet_2 = {
    name                              = "snet-identity-gwc-rootCA"
    address_prefixes                  = "10.10.8.32/27"
    nsg_name                          = "nsg-identity-gwc-rootCA"
    service_delegation                = []
    service_endpoints                 = ["Microsoft.Storage"]
    private_endpoint_network_policies = "Enabled"
  }
}
identity_udr_routes = {
  route_01 = {
    name                   = "udr-identity-gwc"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.10.1.4"
  }
}

# GWC mgmt resources
mgmt_sub_id               = "<REDACTED>"
mgmt_resource_group       = "rg-mgmt-gwc-net"
mgmt_vnet_name            = "vnet-mgmt-gwc"
mgmt_vnet_location        = "germanywestcentral"
mgmt_vnet_cidr            = "10.10.10.0/23"
mgmt_udr_name             = "rt-mgmt-gwc"
mgmt_peer_remote_gw       = true
mgmt_peer_gateway_transit = true

mgmt_vnet_subnets = {
  subnet_1 = {
    name                              = "snet-mgmt-gwc-servers"
    address_prefixes                  = "10.10.10.0/27"
    nsg_name                          = "nsg-mgmt-gwc-servers"
    service_delegation                = []
    service_endpoints                 = ["Microsoft.Storage"]
    private_endpoint_network_policies = "Enabled"
  }
}
mgmt_udr_routes = {
  route_01 = {
    name                   = "udr-mgmt-gwc"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.10.1.4"
  }
}
