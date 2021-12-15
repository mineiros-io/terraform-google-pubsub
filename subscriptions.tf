locals {
  subscriptions     = concat(var.push_subscriptions, var.pull_subscriptions)
  subscriptions_map = { for s in local.subscriptions : s.name => s }
}

# TODO convert to module and provide upgrade path
resource "google_pubsub_subscription" "subscription" {
  for_each = var.module_enabled ? local.subscriptions_map : tomap({})

  project = var.project

  topic = google_pubsub_topic.topic.0.name

  name = each.key

  labels                     = merge(var.subscription_labels, try(each.value.labels, {}))
  ack_deadline_seconds       = try(each.value.ack_deadline_seconds, null)
  message_retention_duration = try(each.value.message_retention_duration, "604800s")
  retain_acked_messages      = try(each.value.retain_acked_messages, null)
  filter                     = try(each.value.filter, null)
  enable_message_ordering    = try(each.value.enable_message_ordering, null)

  # DEFAULT: if the attribute does not exist use "" unlimited expiration - (do not expire)
  # if ttl = `null` do not add the block (force default of 31d)
  # if set, use what ever has been set. (users whish is our command ;))
  dynamic "expiration_policy" {
    for_each = try(each.value.expiration_policy_ttl, "") != null ? [1] : []

    content {
      ttl = try(each.value.expiration_policy_ttl, "")
    }
  }

  dynamic "dead_letter_policy" {
    for_each = can(each.value.dead_letter_policy.dead_letter_topic) ? [1] : []

    content {
      dead_letter_topic     = each.value.dead_letter_policy.dead_letter_topic
      max_delivery_attempts = try(each.value.dead_letter_policy.max_delivery_attempts, 5)
    }
  }

  dynamic "retry_policy" {
    for_each = can(each.value.retry_policy) ? [1] : []

    content {
      minimum_backoff = try(each.value.retry_policy.minimum_backoff, null)
      maximum_backoff = try(each.value.retry_policy.maximum_backoff, null)
    }
  }

  dynamic "push_config" {
    for_each = can(each.value.push_config) ? [1] : []

    content {
      push_endpoint = each.value.push_config.push_endpoint
      attributes    = try(each.value.push_config.attributes, {})

      dynamic "oidc_token" {
        for_each = can(each.value.push_config.oidc_token) ? [1] : []

        content {
          service_account_email = each.value.push_config.oidc_token.service_account_email
          audience              = try(each.value.push_config.oidc_token.audience, null)
        }
      }
    }
  }

  depends_on = [var.module_depends_on]
}

locals {
  # prepare inputs for submodule pubsub-subscription-iam
  # for each subscription merge iam with the subscription name
  pull_subscriptions_iam = flatten([
    for subscription in var.pull_subscriptions : [
      for iam in try(subscription.iam, []) :
      merge(iam, { subscription_name = subscription.name })
    ]
  ])

  pull_subscriptions_iam_map = {
    for iam in local.pull_subscriptions_iam :
    "${iam.subscription_name}/${iam.role}" => iam
  }
}

module "subscription-iam" {
  source = "github.com/mineiros-io/terraform-google-pubsub-subscription-iam?ref=v0.0.2"

  for_each = var.module_enabled ? local.pull_subscriptions_iam_map : {}

  project = var.project

  subscription = google_pubsub_subscription.subscription[each.value.subscription_name].id

  role          = each.value.role
  members       = try(each.value.members, [])
  authoritative = try(each.value.authoritative, true)

  module_enabled    = var.module_enabled
  module_depends_on = var.module_depends_on
}

# DEPRECATED single member per subscription

locals {
  iam_pull_subscriptions_map = { for s in var.pull_subscriptions : s.name => s if can(s.iam_member) }
}

# enable each pull subscriptions to be subscribed to by a iam member.
resource "google_pubsub_subscription_iam_member" "pull_subscription_iam_member" {
  for_each = var.module_enabled ? local.iam_pull_subscriptions_map : {}

  project = var.project

  subscription = each.key

  role   = "roles/pubsub.subscriber"
  member = each.value.iam_member

  depends_on = [var.module_depends_on, google_pubsub_subscription.subscription]
}
