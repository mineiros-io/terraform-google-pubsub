# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# COMPLETE FEATURES UNIT TEST
# This module tests a complete set of most/all non-exclusive features
# The purpose is to activate everything the module offers, but trying to keep execution time and costs minimal.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

variable "gcp_region" {
  type        = string
  description = "(Required) The gcp region in which all resources will be created."
}

variable "gcp_project" {
  type        = string
  description = "(Required) The ID of the project in which the resource belongs."
}

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  region  = var.gcp_region
  project = var.gcp_project
}

module "publish-service-account" {
  source = "github.com/mineiros-io/terraform-google-service-account?ref=v0.0.9"

  account_id = "unit-complete-push"
}

module "pull-service-account" {
  source = "github.com/mineiros-io/terraform-google-service-account?ref=v0.0.9"

  account_id = "unit-complete-pull"
}
# DO NOT RENAME MODULE NAME
module "test" {
  source = "../.."

  module_enabled = true
  project        = var.gcp_project

  # add all required arguments
  topic_name = "unit-complete"

  # add all optional arguments that create additional resources
  publish_iam_members = ["serviceAccount:${module.publish-service-account.precomputed_email}"]

  push_subscriptions = [
    {
      name                       = "example.subscription"
      message_retention_duration = "3600s"
      push_config = {
        push_endpoint = "https://mineiros.io/pubsub"
        oidc_token = {
          service_account_email = "serviceAccount:${module.pull-service-account.precomputed_email}"
        }
      }
    }
  ]

  pull_subscriptions = [
    {
      name = "pull.messages"

      # subscription settings
      labels                     = { env = "test" }
      ack_deadline_seconds       = null
      message_retention_duration = "604800s" // 7 days
      retain_acked_messages      = true
      filter                     = null
      enable_message_ordering    = true

      # iam access (roles to grant identities on the subscription)
      iam = [
        {
          role    = "roles/pubsub.subscriber"
          members = ["serviceAccount:${module.pull-service-account.precomputed_email}"]
        }
      ]
    },
  ]

  # add most/all other optional arguments
  topic_labels = {
    name = "UnitComplete"
  }

  subscription_labels = {
    name = "UnitComplete"
  }

  allowed_persistence_regions = [
    "europe-west3-a",
    "europe-west3-b",
  ]

  # module_timeouts = {
  #   google_monitoring_notification_channel = {
  #     create = "10m"
  #     update = "10m"
  #     delete = "10m"
  #   }
  # }

  module_depends_on = ["nothing"]
}

# outputs generate non-idempotent terraform plans so we disable them for now unless we need them.
# output "all" {
#   description = "All outputs of the module."
#   value       = module.test
# }
