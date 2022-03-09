header {
  image = "https://raw.githubusercontent.com/mineiros-io/brand/3bffd30e8bdbbde32c143e2650b2faa55f1df3ea/mineiros-primary-logo.svg"
  url   = "https://mineiros.io/?ref=terraform-google-pubsub"

  badge "build" {
    image = "https://github.com/mineiros-io/terraform-google-pubsub/workflows/Tests/badge.svg"
    url   = "https://github.com/mineiros-io/terraform-google-pubsub/actions"
    text  = "Build Status"
  }

  badge "semver" {
    image = "https://img.shields.io/github/v/tag/mineiros-io/terraform-google-pubsub.svg?label=latest&sort=semver"
    url   = "https://github.com/mineiros-io/terraform-google-pubsub/releases"
    text  = "GitHub tag (latest SemVer)"
  }

  badge "terraform" {
    image = "https://img.shields.io/badge/Terraform-1.x-623CE4.svg?logo=terraform"
    url   = "https://github.com/hashicorp/terraform/releases"
    text  = "Terraform Version"
  }

  badge "tf-gcp-provider" {
    image = "https://img.shields.io/badge/google-4-1A73E8.svg?logo=terraform"
    url   = "https://github.com/terraform-providers/terraform-provider-google/releases"
    text  = "Google Provider Version"
  }

  badge "slack" {
    image = "https://img.shields.io/badge/slack-@mineiros--community-f32752.svg?logo=slack"
    url   = "https://mineiros.io/slack"
    text  = "Join Slack"
  }
}

section {
  title   = "terraform-google-pubsub"
  toc     = true
  content = <<-END
    A [Terraform](https://www.terraform.io) module for managing a [Cloud Pub/Sub](https://cloud.google.com/pubsub)
    resource on [Google Cloud](https://cloud.google.com/)

    **_This module supports Terraform version 1
    and is compatible with the Terraform Google Provider version 4._**

    This module is part of our Infrastructure as Code (IaC) framework
    that enables our users and customers to easily deploy and manage reusable,
    secure, and production-grade cloud infrastructure.
  END

  section {
    title   = "Module Features"
    content = <<-END
      This module implements the following Terraform resources

      - `google_pubsub_topic`
      - `google_pubsub_topic_iam_member`
      - `google_pubsub_subscription`
      - `google_pubsub_subscription_iam_member`

      and supports additional features of the following modules:

      - [mineiros-io/subscription-iam](https://github.com/mineiros-io/terraform-google-pubsub-subscription-iam)
    END
  }

  section {
    title   = "Getting Started"
    content = <<-END
      Most common usage of the module:

      ```hcl
      module "terraform-google-pubsub" {
        source = "git@github.com:mineiros-io/terraform-google-pubsub.git?ref=v0.0.4"

        topic_name = "name"
        project    = "project-id"
      }
      ```
    END
  }

  section {
    title   = "Module Argument Reference"
    content = <<-END
      See [variables.tf] and [examples/] for details and use-cases.
    END

    section {
      title = "Main Resource Configuration"

      variable "topic_name" {
        required    = true
        type        = string
        description = <<-END
          The name of the Cloud Pub/Sub Topic.
        END
      }

      variable "project" {
        required    = true
        type        = string
        description = <<-END
          The project in which the resource belongs. If it is not provided, the
          provider project is used.
        END
      }

      variable "topic_labels" {
        type        = map(string)
        default     = {}
        description = <<-END
          A map of labels to assign to the Pub/Sub topic.
        END
      }

      variable "kms_key_name" {
        type        = string
        description = <<-END
          The resource name of the Cloud KMS CryptoKey to be used to protect
          access to messages published on this topic. Your project's PubSub
          service account
          (`service-{{PROJECT_NUMBER}}@gcp-sa-pubsub.iam.gserviceaccount.com`)
          must have `roles/cloudkms.cryptoKeyEncrypterDecrypter` to use this
          feature. The expected format is
          `projects/*/locations/*/keyRings/*/cryptoKeys/*`
        END
      }

      variable "publish_iam_members" {
        type        = set(string)
        default     = []
        description = <<-END
          A list of iam members to gran publish access to the topic
        END
      }

      variable "publish_iam_members" {
        type        = set(string)
        default     = []
        description = <<-END
          A list of iam members to gran publish access to the topic
        END
      }

      variable "allowed_persistence_regions" {
        type        = set(string)
        default     = []
        description = <<-END
          A list of IDs of GCP regions where messages that are published to the
          topic may be persisted in storage. Messages published by publishers
          running in non-allowed GCP regions (or running outside of GCP
          altogether) will be routed for storage in one of the allowed regions.
          An empty list means that no regions are allowed, and is not a valid
          configuration.
        END
      }
    }

    section {
      title = "Extended Resource Configuration"

      variable "subscription_labels" {
        type        = map(string)
        default     = {}
        description = <<-END
          A map of labels to assign to all created Pub/Sub subscriptions.
        END
      }

      variable "push_subscriptions" {
        type           = list(push_subscription)
        default        = []
        description    = <<-END
          The list of the push subscriptions that will be created for the PubSub
          topic.
        END
        readme_example = <<-END
          pull_subscriptions = [
            {
              name = "my-subs"

              # subscription settings
              labels                     = {..}
              ack_deadline_seconds       = null
              message_retention_duration = "604800s"
              retain_acked_messages      = null
              filter                     = null
              enable_message_ordering    = null

              # iam access (roles to grant identities on the subscription)
              iam = [
                {
                  role          = "roles/pubsub.subscriber"
                  members       = [...]
                  authoritative = true
                }
              ]
            },
          ]
        END

        attribute "labels" {
          type        = map(string)
          description = <<-END
            A set of key/value label pairs to assign to this Subscription.
          END
        }

        attribute "ack_deadline_seconds" {
          type        = number
          description = <<-END
            This value is the maximum time after a subscriber receives a message
            before the subscriber should acknowledge the message. After message
            delivery but before the ack deadline expires and before the message
            is acknowledged, it is an outstanding message and will not be
            delivered again during that time (on a best-effort basis). For pull
            subscriptions, this value is used as the initial value for the ack
            deadline. To override this value for a given message, call
            `subscriptions.modifyAckDeadline` with the corresponding `ackId` if
            using pull. The minimum custom deadline you can specify is `10`
            seconds. The maximum custom deadline you can specify is `600` seconds
            (10 minutes). If this parameter is 0, a default value of `10` seconds
            is used. For push delivery, this value is also used to set the
            request timeout for the call to the push endpoint. If the subscriber
            never acknowledges the message, the Pub/Sub system will eventually
            redeliver the message.
          END
        }

        attribute "message_retention_duration" {
          type        = string
          description = <<-END
            How long to retain unacknowledged messages in the subscription's
            backlog, from the moment a message is published. If
            `retainAckedMessages` is `true`, then this also configures the
            retention of acknowledged messages, and thus configures how far back
            in time a `subscriptions.seek` can be done. Defaults to 7 days.
            Cannot be more than 7 days (`604800s`) or less than 10 minutes
            (`600s`). A duration in seconds with up to nine fractional digits,
            terminated by `s`. 
          END
        }

        attribute "retain_acked_messages" {
          type        = bool
          description = <<-END
            Indicates whether to retain acknowledged messages. If `true`, then
            messages are not expunged from the subscription's backlog, even if
            they are acknowledged, until they fall out of the
            `messageRetentionDuration` window.
          END
        }

        attribute "filter" {
          type        = string
          description = <<-END
            The subscription only delivers the messages that match the filter.
            Pub/Sub automatically acknowledges the messages that don't match the
            filter. You can filter messages by their attributes. The maximum
            length of a filter is 256 bytes. After creating the subscription,
            you can't modify the filter.
          END
        }

        attribute "enable_message_ordering" {
          type        = bool
          description = <<-END
            If `true`, messages published with the same `orderingKey` in
            `PubsubMessage` will be delivered to the subscribers in the order
            in which they are received by the Pub/Sub system. Otherwise, they
            may be delivered in any order.
          END
        }

        attribute "iam" {
          type        = list(iam)
          description = <<-END
            List of IAM access roles to grant identities on the subscription.
          END

          attribute "role" {
            type        = string
            description = <<-END
              The role that should be applied. Only one
              `google_pubsub_subscription_iam_binding` can be used per role.
              Note that custom roles must be of the format
              `[projects|organizations]/{parent-name}/roles/{role-name}`.
            END
          }

          attribute "members" {
            type        = set(string)
            default     = []
            description = <<-END
              Identities that will be granted the privilege in role. Each entry
              can have one of the following values:

              - `allUsers`: A special identifier that represents anyone who is on
                the internet; with or without a Google account.
              - `allAuthenticatedUsers`: A special identifier that represents
                anyone who is authenticated with a Google account or a service
                account.
              - `user:{emailid}`: An email address that represents a specific
                Google account. For example, `alice@gmail.com` or `joe@example.com`.
              - `serviceAccount:{emailid}`: An email address that represents a
                service account. For example,
                `my-other-app@appspot.gserviceaccount.com`.
              - `group:{emailid}`: An email address that represents a Google
                group. For example, `admins@example.com`.
              - `domain:{domain}`: A G Suite domain (primary, instead of alias)
                name that represents all the users of that domain. For example,
                `google.com` or `example.com`.
            END
          }

          attribute "authoritative" {
            type        = bool
            default     = true
            description = <<-END
              Whether to exclusively set (authoritative mode) or add
              (non-authoritative/additive mode) members to the role.
            END
          }
        }
      }
    }

    section {
      title = "Module Configuration"

      variable "module_enabled" {
        type        = bool
        default     = true
        description = <<-END
          Specifies whether resources in the module will be created.
        END
      }

      variable "module_depends_on" {
        type           = list(dependency)
        description    = <<-END
          A list of dependencies.
          Any object can be _assigned_ to this list to define a hidden external dependency.
        END
        default        = []
        readme_example = <<-END
          module_depends_on = [
            null_resource.name
          ]
        END
      }
    }
  }

  section {
    title   = "Module Outputs"
    content = <<-END
      The following attributes are exported in the outputs of the module:
    END

    output "topic" {
      type        = object(topic)
      description = <<-END
        The created pub sub resource.
      END
    }

    output "push_subscriptions" {
      type        = list(push_subscription)
      description = <<-END
        The created push pub sub subscriptions.
      END
    }

    output "pull_subscriptions" {
      type        = list(pull_subscription)
      description = <<-END
        The created pull pub sub subscriptions.
      END
    }

    output "module_enabled" {
      type        = bool
      description = <<-END
        Whether this module is enabled.
      END
    }
  }

  section {
    title = "External Documentation"

    section {
      title   = "Google  Documentation"
      content = <<-END
        - https://cloud.google.com/pubsub
      END
    }

    section {
      title   = "Terraform GPC Provider Documentation"
      content = <<-END
        - Topic: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic
        - Topic IAM: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic_iam
        - Subscription: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_subscription
        - Subscription IAM: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_subscription_iam
      END
    }
  }

  section {
    title   = "Module Versioning"
    content = <<-END
      This Module follows the principles of [Semantic Versioning (SemVer)].

      Given a version number `MAJOR.MINOR.PATCH`, we increment the:

      1. `MAJOR` version when we make incompatible changes,
      2. `MINOR` version when we add functionality in a backwards compatible manner, and
      3. `PATCH` version when we make backwards compatible bug fixes.
    END

    section {
      title   = "Backwards compatibility in `0.0.z` and `0.y.z` version"
      content = <<-END
        - Backwards compatibility in versions `0.0.z` is **not guaranteed** when `z` is increased. (Initial development)
        - Backwards compatibility in versions `0.y.z` is **not guaranteed** when `y` is increased. (Pre-release)
      END
    }
  }

  section {
    title   = "About Mineiros"
    content = <<-END
      [Mineiros][homepage] is a remote-first company headquartered in Berlin, Germany
      that solves development, automation and security challenges in cloud infrastructure.

      Our vision is to massively reduce time and overhead for teams to manage and
      deploy production-grade and secure cloud infrastructure.

      We offer commercial support for all of our modules and encourage you to reach out
      if you have any questions or need help. Feel free to email us at [hello@mineiros.io] or join our
      [Community Slack channel][slack].
    END
  }

  section {
    title   = "Reporting Issues"
    content = <<-END
      We use GitHub [Issues] to track community reported issues and missing features.
    END
  }

  section {
    title   = "Contributing"
    content = <<-END
      Contributions are always encouraged and welcome! For the process of accepting changes, we use
      [Pull Requests]. If you'd like more information, please see our [Contribution Guidelines].
    END
  }

  section {
    title   = "Makefile Targets"
    content = <<-END
      This repository comes with a handy [Makefile].
      Run `make help` to see details on each available target.
    END
  }

  section {
    title   = "License"
    content = <<-END
      [![license][badge-license]][apache20]

      This module is licensed under the Apache License Version 2.0, January 2004.
      Please see [LICENSE] for full details.

      Copyright &copy; 2020-2022 [Mineiros GmbH][homepage]
    END
  }
}

references {
  ref "homepage" {
    value = "https://mineiros.io/?ref=terraform-google-pubsub"
  }
  ref "hello@mineiros.io" {
    value = " mailto:hello@mineiros.io"
  }
  ref "badge-license" {
    value = "https://img.shields.io/badge/license-Apache%202.0-brightgreen.svg"
  }
  ref "releases-terraform" {
    value = "https://github.com/hashicorp/terraform/releases"
  }
  ref "releases-aws-provider" {
    value = "https://github.com/terraform-providers/terraform-provider-aws/releases"
  }
  ref "apache20" {
    value = "https://opensource.org/licenses/Apache-2.0"
  }
  ref "slack" {
    value = "https://mineiros.io/slack"
  }
  ref "terraform" {
    value = "https://www.terraform.io"
  }
  ref "aws" {
    value = "https://aws.amazon.com/"
  }
  ref "semantic versioning (semver)" {
    value = "https://semver.org/"
  }
  ref "variables.tf" {
    value = "https://github.com/mineiros-io/terraform-google-pubsub/blob/main/variables.tf"
  }
  ref "examples/" {
    value = "https://github.com/mineiros-io/terraform-google-pubsub/blob/main/examples"
  }
  ref "issues" {
    value = "https://github.com/mineiros-io/terraform-google-pubsub/issues"
  }
  ref "license" {
    value = "https://github.com/mineiros-io/terraform-google-pubsub/blob/main/LICENSE"
  }
  ref "makefile" {
    value = "https://github.com/mineiros-io/terraform-google-pubsub/blob/main/Makefile"
  }
  ref "pull requests" {
    value = "https://github.com/mineiros-io/terraform-google-pubsub/pulls"
  }
  ref "contribution guidelines" {
    value = "https://github.com/mineiros-io/terraform-google-pubsub/blob/main/CONTRIBUTING.md"
  }
}
