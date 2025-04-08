# Azure Hub-and-Spoke Network Infrastructure-as-Code

This folder contains Terraform infrastructure-as-code configurations for deploying the  **GWC (Primary Site - `gwc` folder)** and the **SDC (DR site - `sdc` folder)** network configuration. 

## Overview

The resources defined in the network folders provision the core networking components required for the GWC / SDC environments. 
This includes:

- Resource Groups for the Networks (VNets)
- Virtual Networks (VNets)
- Subnets
- Network Security Groups (NSGs)
- Route Tables
- VNet Peerings
- Required delegation and service endpoints

## Network Folder Structure

- `main.tf`: \
This is the entry point for deploying the relevant network stack.\
It includes references to the required modules and resources needed to provision the network infrastructure.

- `variables.tf`: \
Contains all the input variables used to parameterize the deployment of network resources in the corresponding region setup.

- `hub_spoke_topology.tf`: \
This file defines reusable Terraform modules for the hub-and-spoke network topology.\
It orchestrates the deployment of network components by invoking specific modules for Virtual Network Gateway, Azure Firewall and Policy, Hub, and Spoke configurations.

- `terraform.tfvars`: \
Provides specific values for the input variables defined in variables.tf. \
These are typically environment-specific values like region, CIDR ranges, etc.

- `README.md`: \
Documentation for understanding the files and usage of the network stack.

```
network/
│
gwc/
    │
    ├── main.tf                 # Entry point for deploying the GWC region
    ├── hub_spoke_topology.tf   # Reusable Terraform modules
    ├── terraform.tfvars        # GWC-specific variable values
    └── variables.tf            # Contains all the variables for parameterization
│
sdc/
    │
    ├── main.tf                 # Entry point for deploying the SDC region
    ├── hub_spoke_topology.tf   # Reusable Terraform modules
    ├── terraform.tfvars        # SDC-specific variable values
    └── variables.tf            # Contains all the variables for parameterization
│
└── README.md               # General network documentation
```

## Modules Folder Structure

```
├───azure_firewall-v2
│       main.tf
│       output.tf
│       variables.tf
│
├───hub_network
│       main.tf
│       output.tf
│       variables.tf
│
├───spoke_network
│       main.tf
│       main.tf.old
│       output.tf
│       variables.tf
│
└───vpn_gateway
        main.tf
        variables.tf
```

## Deployment Instructions

#### 1. Deploying Locally Using the CLI

To deploy the Terraform configuration locally from the command line interface (CLI), follow these steps:

##### Prerequisites

- **Terraform**: Make sure you have Terraform installed on your local machine. You can download it from Terraform's website.
- **Azure CLI**: Install the Azure CLI to authenticate with your Azure subscription.
- **Azure Subscription**: You must have an active Azure subscription and the necessary permissions to create network resources.

##### Steps to Deploy

- Authenticate Azure CLI with your Azure account. \
`az login`

- Initialize Terraform\
`terraform init`

- Review the Terraform changes\
`terraform plan`

- Apply the Terraform Configuration\
`terraform apply`

#### 2. Automating Deployment Using Azure DevOps or GitHub Actions

By configuring CI/CD pipelines, Azure DevOps or GitHub Actions can automate the process of initializing Terraform, applying configurations, and managing Azure resources.