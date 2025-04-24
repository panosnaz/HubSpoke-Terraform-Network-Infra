# SDC Hub resources
conn_sub_id        = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
hub_resource_group = "rg-connectivity-sdc-net"

hub_location  = "swedencentral"
hub_vnet_name = "vnet-connectivity-sdc"
hub_vnet_cidr = "10.20.0.0/21"

gateway_subnet                 = "10.20.0.0/24"
firewall_subnet                = "10.20.1.0/24"
firewall_name                  = "fw-connectivity-sdc"
firewall_policy_name           = "fw-connectivity-sdc-policy"
firewall_pip_name              = "fw-connectivity-sdc-pip"
firewall_pip_allocation_method = "Static"
firewall_pip_sku               = "Standard"
firewall_sku_tier              = "Premium"
firewall_zones                 = ["1", "2", "3"]
bastion_subnet                 = "10.20.2.64/26"
bastion_host                   = "bastion-connectivity-sdc"
bastion_ip                     = "bastion-connectivity-sdc-pip"

conn_vnet_subnets = {
  subnet_1 = {
    name             = "snet-connectivity-sdc-devops"
    address_prefixes = "10.20.2.0/28"
    nsg_name         = "nsg-connectivity-sdc-devops"
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
    name                              = "snet-connectivity-sdc-storagePE"
    address_prefixes                  = "10.20.2.16/28"
    nsg_name                          = "nsg-connectivity-sdc-storagePE"
    service_delegation                = []
    service_endpoints                 = ["Microsoft.Storage"]
    private_endpoint_network_policies = "Disabled"
  }
}

# SDC HUB VPN Gateway
vpn_gateway_location                      = "swedencentral"
vpn_gateway_pip_name                      = "vgw-connectivity-sdc-pip"
vpn_gateway_name                          = "vgw-connectivity-sdc"
vpn_gateway_sku                           = "VpnGw3AZ"
vpn_gateway_type                          = "Vpn"
vpn_gateway_vpn_type                      = "RouteBased"
vpn_gateway_private_ip_address_allocation = "Dynamic"
hub_vpn_gateway1_pip_sku                  = "Standard"
hub_vpn_gateway1_pip_allocation_method    = "Static"
hub_vpn_gateway1_pip_zones                = ["1", "2", "3"]
vpn_gateway_udr_name                      = "rt-connectivity-sdc-vgw"
vpn_gateway_udr_routes = {

  route_01 = {
    name                   = "udr-prod-sdc"
    address_prefix         = "10.20.12.0/22"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.20.1.4"
  }
  route_02 = {
    name                   = "udr-identity-sdc"
    address_prefix         = "10.20.8.0/23"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.20.1.4"
  }
  route_03 = {
    name                   = "udr-dev-sdc"
    address_prefix         = "10.20.16.0/22"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.20.1.4"
  }
  route_04 = {
    name                   = "udr-mgmt-sdc"
    address_prefix         = "10.20.10.0/23"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.20.1.4"
  }
}
vpn_client_address_space = ["10.20.252.0/22"]
vpn_auth_types           = ["Certificate"]
root_certificate_name    = "rootCA"
public_cert_data         = <<EOF
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
EOF

vpn_client_protocols = ["OpenVPN"]
vpn_gateway_custom_route_address_prefixes = [
  "10.20.0.0/16"
]

############################
# S2S onprem VPN to SDC HUB
############################
local_network_gateway_name = "lgw-connectivity-sdc"
vpn_connection_name        = "vgw-connectivity-sdc-s2s-onpremises"
vpn_connection_type        = "IPsec"
local_network_gateway_pip  = "xx.xx.xx.xx"
local_network_address_space = [
  "192.168.1.0/25",
  "192.168.2.0/25",
  "192.168.3.0/24"
]

ipsec_shared_key = "xxxxxxxxx"

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
            source_addresses  = ["10.20.8.0/27"]
            destination_ports = ["1688"]
            destination_fqdns = ["azkms.core.windows.net"]
            protocols         = ["TCP"]
          },
          {
            name                  = "DCs-To-Monitor"
            source_addresses      = ["10.20.8.0/27"]
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
            source_addresses      = ["192.168.13.3/32", "192.168.13.4/32"]
            destination_ports     = ["49443", "464", "88", "3268", "3269", "636", "389", "137", "49152-65535", "135", "445", "5985", "53", "123", "138", "139", "3389"]
            destination_addresses = ["10.20.8.4/32", "10.20.8.5/32"]
            protocols             = ["TCP"]
          },
          {
            name                  = "onprem_udp_access_to_DC"
            source_addresses      = ["192.168.13.3/32", "192.168.13.4/32"]
            destination_ports     = ["464", "88", "389", "137", "135", "53", "123", "138", "139", "3389"]
            destination_addresses = ["10.20.8.4/32", "10.20.8.5/32"]
            protocols             = ["UDP"]
          },
          {
            name                  = "DC_tcp_access_to_onprem"
            source_addresses      = ["10.20.8.4/32", "10.20.8.5/32"]
            destination_ports     = ["49443", "464", "88", "3268", "3269", "636", "389", "137", "49152-65535", "135", "445", "5985", "53", "123", "138", "139", "3389"]
            destination_addresses = ["192.168.13.3/32", "192.168.13.4/32"]
            protocols             = ["TCP"]
          },
          {
            name                  = "DC_udp_access_to_onprem"
            source_addresses      = ["10.20.8.4/32", "10.20.8.5/32"]
            destination_ports     = ["464", "88", "389", "137", "135", "53", "123", "138", "139", "3389"]
            destination_addresses = ["192.168.13.3/32", "192.168.13.4/32"]
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
            source_addresses  = ["10.20.8.0/27", "10.20.8.160/27"]
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
            source_addresses      = ["10.20.8.0/27", "10.20.8.160/27"]
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
      }
      "DevOps" = {
        action = "Allow"
        rules = [
          {
            name              = "DevOpsPoolComs"
            source_addresses  = ["10.20.10.128/28"]
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
      #       destination_address = "9.141.10.10"
      #       translated_port     = "3389"
      #       translated_address  = "10.200.13.5"
      #       protocols           = ["TCP"]
      #     }
      #   ]
      # }
    }
  }
}

# SDC PROD resources
prod_sub_id         = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
prod_resource_group = "rg-prod-sdc-net"
prod_vnet_name      = "vnet-prod-sdc"
prod_vnet_location  = "swedencentral"
prod_vnet_cidr      = "10.20.12.0/22"
prod_udr_name       = "rt-prod-sdc"

prod_vnet_subnets = {
  subnet_1 = {
    name                              = "snet-prod-sdc-app"
    address_prefixes                  = "10.20.12.0/25"
    nsg_name                          = "nsg-prod-sdc-app"
    service_delegation                = []
    service_endpoints                 = ["Microsoft.Storage"]
    private_endpoint_network_policies = "Enabled"
  },
  subnet_2 = {
    name                              = "snet-prod-sdc-db"
    address_prefixes                  = "10.20.12.128/25"
    nsg_name                          = "nsg-prod-sdc-db"
    service_delegation                = []
    service_endpoints                 = ["Microsoft.Storage"]
    private_endpoint_network_policies = "Enabled"
  }
  subnet_3 = {
    name                              = "snet-prod-sdc-keyvault"
    address_prefixes                  = "10.20.13.0/27"
    nsg_name                          = "nsg-prod-sdc-keyvault"
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
    next_hop_in_ip_address = "10.20.1.4"
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


# SDC DEV resources
dev_sub_id               = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
dev_resource_group       = "rg-dev-sdc-net"
dev_vnet_name            = "vnet-dev-sdc"
dev_vnet_location        = "swedencentral"
dev_vnet_cidr            = "10.20.16.0/22"
dev_udr_name             = "rt-dev-sdc"
dev_peer_remote_gw       = true
dev_peer_gateway_transit = true

dev_vnet_subnets = {
  subnet_1 = {
    name                              = "snet-dev-sdc-app"
    address_prefixes                  = "10.20.16.0/25"
    nsg_name                          = "nsg-dev-sdc-app"
    service_delegation                = []
    service_endpoints                 = ["Microsoft.Storage"]
    private_endpoint_network_policies = "Enabled"
  },
  subnet_2 = {
    name                              = "snet-dev-sdc-db"
    address_prefixes                  = "10.20.16.128/25"
    nsg_name                          = "nsg-dev-sdc-db"
    service_delegation                = []
    service_endpoints                 = ["Microsoft.Storage"]
    private_endpoint_network_policies = "Enabled"
  }
}
dev_udr_routes = {
  route_01 = {
    name                   = "udr-dev-sdc"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.20.1.4"
  }
}

# SDC identity resources
identity_sub_id               = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
identity_resource_group       = "rg-identity-sdc-net"
identity_vnet_name            = "vnet-identity-sdc"
identity_vnet_location        = "swedencentral"
identity_vnet_cidr            = "10.20.8.0/23"
identity_udr_name             = "rt-identity-sdc"
identity_peer_remote_gw       = true
identity_peer_gateway_transit = true

identity_vnet_subnets = {
  subnet_1 = {
    name                              = "snet-identity-sdc-dc"
    address_prefixes                  = "10.20.8.0/27"
    nsg_name                          = "nsg-identity-sdc-dc"
    service_delegation                = []
    service_endpoints                 = ["Microsoft.Storage"]
    private_endpoint_network_policies = "Enabled"
  },
  subnet_2 = {
    name                              = "snet-identity-sdc-rootCA"
    address_prefixes                  = "10.20.8.32/27"
    nsg_name                          = "nsg-identity-sdc-rootCA"
    service_delegation                = []
    service_endpoints                 = ["Microsoft.Storage"]
    private_endpoint_network_policies = "Enabled"
  }
}
identity_udr_routes = {
  route_01 = {
    name                   = "udr-identity-sdc"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.20.1.4"
  }
}

# SDC mgmt resources
mgmt_sub_id               = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
mgmt_resource_group       = "rg-mgmt-sdc-net"
mgmt_vnet_name            = "vnet-mgmt-sdc"
mgmt_vnet_location        = "swedencentral"
mgmt_vnet_cidr            = "10.20.10.0/23"
mgmt_udr_name             = "rt-mgmt-sdc"
mgmt_peer_remote_gw       = true
mgmt_peer_gateway_transit = true

mgmt_vnet_subnets = {
  subnet_1 = {
    name                              = "snet-mgmt-sdc-servers"
    address_prefixes                  = "10.20.10.0/27"
    nsg_name                          = "nsg-mgmt-sdc-servers"
    service_delegation                = []
    service_endpoints                 = ["Microsoft.Storage"]
    private_endpoint_network_policies = "Enabled"
  }
}
mgmt_udr_routes = {
  route_01 = {
    name                   = "udr-mgmt-sdc"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.20.1.4"
  }
}
