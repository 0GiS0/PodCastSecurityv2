provider "azurerm" {

  subscription_id = var.subscription_id

  features {
    cognitive_account {
      purge_soft_delete_on_destroy = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "random_pet" "pet" {
}

resource "azurerm_resource_group" "rg" {
  name     = random_pet.pet.id
  location = "spaincentral"
}



resource "azurerm_storage_account" "storage" {

  name                     = replace(random_pet.pet.id, "-", "")
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

}


resource "azurerm_service_plan" "plan" {
  name                = random_pet.pet.id
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "S1"
}

resource "azurerm_linux_web_app" "web" {

  name                = random_pet.pet.id
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.plan.id

  site_config {
    application_stack {
      node_version = "20-lts"
    }
  }

  storage_account {
    account_name = azurerm_storage_account.storage.name
    mount_path   = "/audios"
    name         = azurerm_storage_account.storage.name
    type         = "AzureFiles"
    share_name   = "audios"
    access_key   = azurerm_storage_account.storage.primary_access_key
  }

  # app_settings = {
  #   "MOVIES_API_URL" : var.movies_api_url
  # }

}

resource "azurerm_cognitive_account" "cognitive_service" {
  name                = random_pet.pet.id
  location            = "swedencentral"
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = var.sku
  kind                = "SpeechServices"
}

resource "azurerm_cognitive_account" "openai" {
  name                = random_pet.pet.id
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "OpenAI"
  sku_name            = "S0"
}

# resource "azurerm_cognitive_deployment" "gpt-4o" {
#   name                 = "gpt-4o"
#   cognitive_account_id = azurerm_cognitive_account.openai.id
#   model {
#     format  = "OpenAI"
#     name    = "gpt-4o"
#     version = "1"
#   }

#   sku {
#     name = "Standard"
#   }

#   depends_on = [azurerm_cognitive_account.openai]
# }
