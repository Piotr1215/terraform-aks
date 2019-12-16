provider "azurerm" {
    version = "=1.39.0"
}

terraform {
    backend "azurerm" {}
}