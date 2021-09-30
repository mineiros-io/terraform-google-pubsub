# ------------------------------------------------------------------------------
# OUTPUT CALCULATED VARIABLES (prefer full objects)
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# OUTPUT ALL RESOURCES AS FULL OBJECTS
# ------------------------------------------------------------------------------

output "topic" {
  value       = try(google_pubsub_topic.topic[0], {})
  description = "The created pub sub resource."
}

output "push_subscriptions" {
  value       = { for s in var.push_subscriptions : s.name => google_pubsub_subscription.subscription[s.name] }
  description = "The created push pub sub subscriptions."
}

output "pull_subscriptions" {
  value       = { for s in var.pull_subscriptions : s.name => google_pubsub_subscription.subscription[s.name] }
  description = "The created pull pub sub subscriptions."
}

# ------------------------------------------------------------------------------
# OUTPUT ALL INPUT VARIABLES
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# OUTPUT MODULE CONFIGURATION
# ------------------------------------------------------------------------------

output "module_enabled" {
  description = "Whether the module is enabled."
  value       = var.module_enabled
}
