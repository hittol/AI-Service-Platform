# ===================================================================
# Create PIP
# ===================================================================

resource "azurerm_public_ip" "appgw_pip" {
  name                = "${var.appgw_name}-pip"
  location            = var.location
  resource_group_name = var.rg_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# ===================================================================
# Create Web Application Firewall
# ===================================================================

resource "azurerm_web_application_firewall_policy" "dh-waf-policy" {
  name                                          = "${var.waf_name}-policy"
  location                                      = var.location
  resource_group_name                           = var.rg_name

  policy_settings {
    enabled                                     = true
    mode                                        = "Prevention"
    request_body_check                          = true
    max_request_body_size_in_kb                 = 128
    file_upload_limit_in_mb                     = 500
  }

  managed_rules {
    managed_rule_set {
        type    = "Microsoft_DefaultRuleSet"
        version = "2.1"
    }
    managed_rule_set { 
        type = "Microsoft_BotManagerRuleSet" 
        version = "1.1" 
        }
  }

  custom_rules {
    name      = "AllowClientIP"
    priority  = 30
    rule_type = "MatchRule"

    match_conditions {
      match_variables {
        variable_name = "RemoteAddr"
      }
      operator           = "IPMatch"
      negation_condition = true
      match_values       = ["1.1.1.1/32"]
    }
    action = "Block"
  }
}

# ===================================================================
# Create Application Gateway
# ===================================================================

resource "azurerm_application_gateway" "dh-appgw" {
  name                          = var.appgw_name
  location                      = var.location
  resource_group_name           = var.rg_name
  firewall_policy_id            = azurerm_web_application_firewall_policy.dh-waf-policy.id

  sku {
    name                        = "WAF_v2"
    tier                        = "WAF_v2"
  }

  autoscale_configuration {
    min_capacity                = 1
    max_capacity                = 10
  }

  gateway_ip_configuration {
    name                        = "appgw-ip-config"
    subnet_id                   = var.appgw-subnet_id
  }

  frontend_ip_configuration {
    name                        = "appgw-frontend-ip"
    public_ip_address_id        = azurerm_public_ip.appgw_pip.id
  }

  frontend_port {
    name = "appgw-frontend-port"
    port = 80
  }

  backend_address_pool {
    name         = "appgw-backend-pool"
    ip_addresses = [var.app_pe_ipaddress]
  }

  backend_http_settings {
    name                  = "appgw-backend-http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 20
  }

  http_listener {
    name                           = "appgw-http-listener"
    frontend_ip_configuration_name = "appgw-frontend-ip"
    frontend_port_name             = "appgw-frontend-port"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "appgw-routing-rule"
    priority                   = 9
    rule_type                  = "Basic"
    http_listener_name         = "appgw-http-listener"
    backend_address_pool_name  = "appgw-backend-pool"
    backend_http_settings_name = "appgw-backend-http-settings"
  }
}