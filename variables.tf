# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED VARIABLES
# These variables must be set when using this module.
# ---------------------------------------------------------------------------------------------------------------------

variable "topic_name" {
  type        = string
  description = "(Required) The name of the Pub/Sub topic."
}

variable "region" {
  description = "(Required) The region to host the VPC and all related resources in."
  type        = string
}

variable "project" {
  description = "(Required) The ID of the project in which the resources belong."
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL VARIABLES
# These variables have defaults, but may be overridden.
# ---------------------------------------------------------------------------------------------------------------------

variable "topic_labels" {
  type        = map(string)
  description = "(Optional) A map of labels to assign to the Pub/Sub topic. Default is '{}'."
  #
  # Example:
  #
  # topic_labels = {
  #   CreatedAt = "2021-03-31",
  #   foo       = "bar"
  # }
  #
  default = {}
}

variable "subscription_labels" {
  type        = map(string)
  description = "(Optional) A map of labels to assign to all created Pub/Sub subscriptions. Default is '{}'."
  #
  # Example:
  #
  # topic_labels = {
  #   CreatedAt = "2021-03-31",
  #   foo       = "bar"
  # }
  #
  default = {}
}

variable "kms_key_name" {
  type        = string
  description = "(Optional) The resource name of the Cloud KMS CryptoKey to be used to protect access to messages published on this topic. Default is 'null'."
  default     = null
}

variable "default_service_account" {
  type        = string
  description = "(Optional) If set, the service account will be used for all subscriptions. Otherwise, the module will look for a service account to be set in each subscription and use the PubSubs default service account if none is provided. Default is 'null'."
  default     = null

}

variable "publish_iam_members" {
  type        = set(string)
  description = "(Optional) A list of iam members to gran publish access to the topic"
  default     = []
}

variable "allowed_persistence_regions" {
  type        = set(string)
  description = "(Optional) A list of persistence regions. Default inherits from organization's Resource Location Restriction policy. Default is '{}'."
  default     = null
}

variable "push_subscriptions" {
  type = any
  # type        = list(map(string))
  description = "(Optional) The list of the push subscriptions that will be created for the PubSub topic. Default is '[]'."
  default     = []
}

# Example:
#   pull_subscriptions = [
#     {
#       name = "my-subs"
#
#       # subscription settings
#       labels                     = {..}
#       ack_deadline_seconds       = null
#       message_retention_duration = "604800s"
#       retain_acked_messages      = null
#       filter                     = null
#       enable_message_ordering    = null
#
#       # iam access (roles to grant identities on the subscription)
#       iam = [
#         {
#           role          = "roles/pubsub.subscriber"
#           members       = [...]
#           authoritative = true
#         }
#       ]
#     },
#   ]
#
variable "pull_subscriptions" {
  type = any
  # type        = list(map(string))
  description = "(Optional) The list of pull subscriptions that will be created for the PubSub topic. Default is '[]'."
  default     = []
}

# ------------------------------------------------------------------------------
# MODULE CONFIGURATION PARAMETERS
# These variables are used to configure the module.
# See https://medium.com/mineiros/the-ultimate-guide-on-how-to-write-terraform-modules-part-1-81f86d31f024
# ------------------------------------------------------------------------------

variable "module_enabled" {
  type        = bool
  description = "(Optional) Whether to create resources within the module or not. Default is 'true'."
  default     = true
}

variable "module_depends_on" {
  type        = any
  description = "(Optional) A list of external resources the module depends_on. Default is '[]'."
  default     = []
}
