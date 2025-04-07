terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.23.0"
    }
  }

  backend "azurerm" {}
}

# Configure the Microsoft Azure Provider per subscription
provider "azurerm" {
  alias = "connectivity"

  features {}
  # Use environment variable TF_VAR_conn_sub_id
  subscription_id = var.conn_sub_id
}

provider "azurerm" {
  alias = "prod"

  features {}
  subscription_id = var.prod_sub_id
}

provider "azurerm" {
  alias = "dev"

  features {}
  # Use environment variable TF_VAR_dev_sub_id
  subscription_id = var.dev_sub_id
}

provider "azurerm" {
  alias = "identity"

  features {}
  # Use environment variable TF_VAR_dev_sub_id
  subscription_id = var.identity_sub_id
}
provider "azurerm" {
  alias = "mgmt"

  features {}
  # Use environment variable TF_VAR_dev_sub_id
  subscription_id = var.mgmt_sub_id
}
