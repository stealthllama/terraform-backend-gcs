############################################################################################
# Copyright 2019 Palo Alto Networks.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
############################################################################################

provider "azurerm" {
  version                   = "~> 1.30"
  subscription_id           = "${var.azure_subscription_id}"
  tenant_id                 = "${var.azure_tenant_id}"
  client_id                 = "${var.azure_client_id}"
  client_secret             = "${var.azure_client_secret}"
}

resource "random_id" "suffix" {
  byte_length               = 2
}

resource "azurerm_resource_group" "tfstate-rg" {
  name                      = "Terraform-State-RG${random_id.suffix.dec}"
  location                  = "eastus"
}

resource "azurerm_storage_account" "tfstate-sa" {
  name                      = "tfstate${random_id.suffix.dec}"
  resource_group_name       = "${azurerm_resource_group.tfstate-rg.name}"
  location                  = "eastus"
  account_tier              = "Standard"
  account_replication_type  = "LRS"

  tags = {
    environment             = "Terraform Remote State Store"
  }
}

resource "azurerm_storage_container" "tfstate-blob" {
  name                      = "tfstate"
  resource_group_name       = "${azurerm_resource_group.tfstate-rg.name}"
  storage_account_name      = "${azurerm_storage_account.tfstate-sa.name}"
  container_access_type     = "private"
}
