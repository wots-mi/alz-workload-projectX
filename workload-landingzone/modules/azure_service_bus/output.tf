output "servicebus_namespace_id" {
  description = "The ID of the Service Bus Namespace"
  value       = azurerm_servicebus_namespace.this.id
}

output "queue_ids" {
  description = "IDs of created Service Bus Queues"
  value       = { for k, v in azurerm_servicebus_queue.queues : k => v.id }
}

output "topic_ids" {
  description = "IDs of created Service Bus Topics"
  value       = { for k, v in azurerm_servicebus_topic.topics : k => v.id }
}