# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# EMPTY FEATURES (DISABLED) UNIT TEST
# This module tests an empty set of features.
# The purpose is to verify no resources are created when the module is disabled.
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

# DO NOT RENAME MODULE NAME
module "test" {
  source = "../.."

  module_enabled = false

  # add all required arguments
  topic_name = "unit-disabled"

  # add only required arguments and no optional arguments
  publish_iam_members = ["serviceAccount:disabled@mineiros.io"]

  push_subscriptions = [
    {
      name                       = "disabled.subscription"
      message_retention_duration = "604800s" // 7 days
      push_config = {
        push_endpoint = "http://disabled.io"
        oidc_token = {
          service_account_email = "serviceAccount:disabled@mineiros.io"
        }
      }
    }
  ]

  pull_subscriptions = [
    {
      name = "my-subs"

      # subscription settings
      labels                     = { Env = "test" }
      ack_deadline_seconds       = null
      message_retention_duration = "604800s" // 7 days
      retain_acked_messages      = true
      filter                     = null
      enable_message_ordering    = true

      # iam access (roles to grant identities on the subscription)
      iam = [
        {
          role          = "roles/pubsub.subscriber"
          members       = ["serviceAccount:disabled@mineiros.io"]
          authoritative = true
        }
      ]
    },
  ]
}

# outputs generate non-idempotent terraform plans so we disable them for now unless we need them.
# output "all" {
#   description = "All outputs of the module."
#   value       = module.test
# }
