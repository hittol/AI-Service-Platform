locals {
  firewall_application_rules = {    
    "DefaultApplicationRuleCollectionGroup" = {
      priority = 300
      collection = {
        name     = "Azure-to-Internet"
        priority = 3200
        action   = "Allow"
        rules = [
          {
            name = "Allow_Web"
            protocols = [
              { type = "Http", port = 80 },
              { type = "Https", port = 443 }
            ]
            source_addresses  = [
              module.vnet.hub_subnet_cidrs["JumpSubnet"]
            ]
            destination_fqdns = ["*"]
          }
        ]
      },
      
    }
  }

  firewall_network_rules = {
    "DefaultNetworkRuleCollectionGroup" = {
      priority = 200
      collection = {
        name     = "Azure-to-Internet"
        priority = 2200
        action   = "Allow"
        rules = [
          {
            name      = "Allow_Web"
            protocols = ["TCP", "UDP"]
            source_addresses = [
              module.vnet.hub_subnet_cidrs["JumpSubnet"]
            ]
            destination_addresses = ["*"]
            destination_ports     = ["80", "443"]
          }
        ]
      }
    }
  }

  firewall_dnat_rules = {
    "DefaultDnatRuleCollectionGroup" = {
      priority = 100
      collection = {
        name     = "DNAT-RC1"
        priority = 1000
        action   = "Dnat"
        rules = [
          {
            name                = "AllowRDP_JumpVM"
            protocols           = ["TCP"]
            source_addresses    = ["*"]
            destination_address = "self"
            destination_ports   = "3400"
            translated_address  = module.vm.private_ip_address
            translated_port     = "3389"
          }
        ]
      }
    }
  }
  
  aoai_backend = {
    "backend-0" = {
      backend_name               = "openai-backend-0"
      backend_protocol           = "http"
      backend_url                = "${module.aoai.endpoint["aoai_01"]}openai"
      validate_certificate_chain = true
      validate_certificate_name  = true
    }
    "backend-1" = {
      backend_name               = "openai-backend-1"
      backend_protocol           = "http"
      backend_url                = "${module.aoai.endpoint["aoai_02"]}openai"
      validate_certificate_chain = true
      validate_certificate_name  = true
    }
  }
}