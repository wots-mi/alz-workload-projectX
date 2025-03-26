resource "azurerm_cdn_frontdoor_profile" "this" {
  name                = var.front_door_profile_name
  resource_group_name = var.resource_group_name
  sku_name            = var.front_door_sku_name
  tags                = var.tags
}

resource "azurerm_cdn_frontdoor_endpoint" "this" {
  for_each                 = toset(var.front_door_endpoint_names)
  name                     = each.value
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this.id
  tags                     = var.tags
}

resource "azurerm_cdn_frontdoor_origin_group" "this" {
  for_each = toset(var.front_door_origin_group_names)

  name                     = each.value
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this.id
  session_affinity_enabled = var.session_affinity_enabled

  load_balancing {
    sample_size                 = var.load_balancing.sample_size
    successful_samples_required = var.load_balancing.successful_samples_required
  }

  dynamic "health_probe" {
    for_each = var.health_probe_config != null ? [1] : []
    content {
      path                = var.health_probe_config.path
      request_type        = var.health_probe_config.request_type
      protocol            = var.health_probe_config.protocol
      interval_in_seconds = var.health_probe_config.interval_in_seconds
    }
  }
}

resource "azurerm_cdn_frontdoor_origin" "this" {
  for_each = merge([
    for group_name, origins in var.origin_configs : {
      for origin in origins :
      "${group_name}-${origin.name}" => merge(origin, { group_name = group_name })
    }
  ]...)

  name                          = each.value.name
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.this[each.value.group_name].id

  enabled                        = true
  host_name                      = each.value.host_name
  http_port                      = each.value.http_port
  https_port                     = each.value.https_port
  origin_host_header             = each.value.origin_host_header
  priority                       = each.value.priority
  weight                         = each.value.weight
  certificate_name_check_enabled = each.value.certificate_name_check_enabled
}

resource "azurerm_cdn_frontdoor_route" "this" {
  for_each = merge([
    for endpoint, routes in var.route_configs : {
      for route in routes : 
      "${endpoint}-${route.name}" => merge(route, { endpoint = endpoint })
    }
  ]...)

  name                          = each.value.name
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.this[each.value.endpoint].id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.this[var.endpoint_to_origin_group[each.value.endpoint]].id

  cdn_frontdoor_origin_ids = [
    for origin in var.origin_configs[var.endpoint_to_origin_group[each.value.endpoint]] :
    azurerm_cdn_frontdoor_origin.this["${var.endpoint_to_origin_group[each.value.endpoint]}-${origin.name}"].id
  ]

  supported_protocols    = ["Http", "Https"]
  patterns_to_match      = each.value.patterns_to_match
  forwarding_protocol    = each.value.forwarding_protocol
  link_to_default_domain = true
  https_redirect_enabled = each.value.https_redirect_enabled
}