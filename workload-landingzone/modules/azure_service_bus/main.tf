resource "azurerm_servicebus_namespace" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku
  capacity            = var.capacity
  premium_messaging_partitions = var.premium_messaging_partitions

  dynamic "identity" {
    for_each = var.identity != null ? [var.identity] : []
    content {
      type         = identity.value.type
      identity_ids = lookup(identity.value, "identity_ids", [])
    }
  }

  tags = var.tags
}

# Namespace Authorization Rules
resource "azurerm_servicebus_namespace_authorization_rule" "this" {
  for_each = { for rule in var.authorization_rules : rule.name => rule }

  name         = each.key
  namespace_id = azurerm_servicebus_namespace.this.id

  listen = contains(each.value.rights, "Listen")
  send   = contains(each.value.rights, "Send")
  manage = contains(each.value.rights, "Manage")
}

# Queues
resource "azurerm_servicebus_queue" "queues" {
  for_each = { for queue in var.queues : queue.name => queue }

  name                  = each.key
  namespace_id          = azurerm_servicebus_namespace.this.id
  partitioning_enabled  = lookup(each.value, "partitioning_enabled", false)
}

# Queue Authorization Rules
resource "azurerm_servicebus_queue_authorization_rule" "queue_auth_rules" {
  for_each = { for rule in flatten([
      for queue in var.queues : [
        for rule in lookup(queue, "authorization_rules", []) : {
          queue_name = queue.name
          rule_name  = rule.name
          rights     = rule.rights
        }
      ]
    ]) : "${rule.queue_name}-${rule.rule_name}" => rule
  }

  name     = each.value.rule_name
  queue_id = azurerm_servicebus_queue.queues[each.value.queue_name].id

  listen = contains(each.value.rights, "Listen")
  send   = contains(each.value.rights, "Send")
  manage = contains(each.value.rights, "Manage")
}

# Topics
resource "azurerm_servicebus_topic" "topics" {
  for_each = { for topic in var.topics : topic.name => topic }

  name                 = each.key
  namespace_id         = azurerm_servicebus_namespace.this.id
  partitioning_enabled = lookup(each.value, "partitioning_enabled", false)
}

# Topic Authorization Rules
resource "azurerm_servicebus_topic_authorization_rule" "topic_auth_rules" {
  for_each = { for rule in flatten([
      for topic in var.topics : [
        for rule in lookup(topic, "authorization_rules", []) : {
          topic_name = topic.name
          rule_name  = rule.name
          rights     = rule.rights
        }
      ]
    ]) : "${rule.topic_name}-${rule.rule_name}" => rule
  }

  name     = each.value.rule_name
  topic_id = azurerm_servicebus_topic.topics[each.value.topic_name].id

  listen = contains(each.value.rights, "Listen")
  send   = contains(each.value.rights, "Send")
  manage = contains(each.value.rights, "Manage")
}
