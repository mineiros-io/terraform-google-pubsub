[<img src="https://raw.githubusercontent.com/mineiros-io/brand/3bffd30e8bdbbde32c143e2650b2faa55f1df3ea/mineiros-primary-logo.svg" width="400"/>](https://mineiros.io/?ref=terraform-google-pubsub)

[![Build Status](https://github.com/mineiros-io/terraform-google-pubsub/workflows/Tests/badge.svg)](https://github.com/mineiros-io/terraform-google-pubsub/actions)
[![GitHub tag (latest SemVer)](https://img.shields.io/github/v/tag/mineiros-io/terraform-google-pubsub.svg?label=latest&sort=semver)](https://github.com/mineiros-io/terraform-google-pubsub/releases)
[![Terraform Version](https://img.shields.io/badge/Terraform-1.x-623CE4.svg?logo=terraform)](https://github.com/hashicorp/terraform/releases)
[![Google Provider Version](https://img.shields.io/badge/google-4-1A73E8.svg?logo=terraform)](https://github.com/terraform-providers/terraform-provider-google/releases)
[![Join Slack](https://img.shields.io/badge/slack-@mineiros--community-f32752.svg?logo=slack)](https://mineiros.io/slack)

# terraform-google-pubsub

A [Terraform](https://www.terraform.io) module for managing a [Cloud Pub/Sub](https://cloud.google.com/pubsub)
resource on [Google Cloud](https://cloud.google.com/)

**_This module supports Terraform version 1
and is compatible with the Terraform Google Provider version 4._**

This module is part of our Infrastructure as Code (IaC) framework
that enables our users and customers to easily deploy and manage reusable,
secure, and production-grade cloud infrastructure.


- [Module Features](#module-features)
- [Getting Started](#getting-started)
- [Module Argument Reference](#module-argument-reference)
  - [Main Resource Configuration](#main-resource-configuration)
  - [Extended Resource Configuration](#extended-resource-configuration)
  - [Module Configuration](#module-configuration)
- [Module Outputs](#module-outputs)
- [External Documentation](#external-documentation)
  - [Google  Documentation](#google--documentation)
  - [Terraform GPC Provider Documentation](#terraform-gpc-provider-documentation)
- [Module Versioning](#module-versioning)
  - [Backwards compatibility in `0.0.z` and `0.y.z` version](#backwards-compatibility-in-00z-and-0yz-version)
- [About Mineiros](#about-mineiros)
- [Reporting Issues](#reporting-issues)
- [Contributing](#contributing)
- [Makefile Targets](#makefile-targets)
- [License](#license)

## Module Features

This module implements the following Terraform resources

- `google_pubsub_topic`
- `google_pubsub_topic_iam_member`
- `google_pubsub_subscription`
- `google_pubsub_subscription_iam_member`

and supports additional features of the following modules:

- [mineiros-io/subscription-iam](https://github.com/mineiros-io/terraform-google-pubsub-subscription-iam)

## Getting Started

Most common usage of the module:

```hcl
module "terraform-google-pubsub" {
  source = "git@github.com:mineiros-io/terraform-google-pubsub.git?ref=v0.0.1"

  topic_name = "name"
  project    = "project-id"
}
```

## Module Argument Reference

See [variables.tf] and [examples/] for details and use-cases.

### Main Resource Configuration

- [**`topic_name`**](#var-topic_name): *(**Required** `string`)*<a name="var-topic_name"></a>

  The name of the Cloud Pub/Sub Topic.

- [**`project`**](#var-project): *(**Required** `string`)*<a name="var-project"></a>

  The project in which the resource belongs. If it is not provided, the
  provider project is used.

- [**`topic_labels`**](#var-topic_labels): *(Optional `map(string)`)*<a name="var-topic_labels"></a>

  A map of labels to assign to the Pub/Sub topic.

  Default is `{}`.

- [**`kms_key_name`**](#var-kms_key_name): *(Optional `string`)*<a name="var-kms_key_name"></a>

  The resource name of the Cloud KMS CryptoKey to be used to protect
  access to messages published on this topic. Your project's PubSub
  service account
  (`service-{{PROJECT_NUMBER}}@gcp-sa-pubsub.iam.gserviceaccount.com`)
  must have `roles/cloudkms.cryptoKeyEncrypterDecrypter` to use this
  feature. The expected format is
  `projects/*/locations/*/keyRings/*/cryptoKeys/*`

- [**`publish_iam_members`**](#var-publish_iam_members): *(Optional `set(string)`)*<a name="var-publish_iam_members"></a>

  A list of iam members to gran publish access to the topic

  Default is `[]`.

- [**`publish_iam_members`**](#var-publish_iam_members): *(Optional `set(string)`)*<a name="var-publish_iam_members"></a>

  A list of iam members to gran publish access to the topic

  Default is `[]`.

- [**`allowed_persistence_regions`**](#var-allowed_persistence_regions): *(Optional `set(string)`)*<a name="var-allowed_persistence_regions"></a>

  A list of IDs of GCP regions where messages that are published to the
  topic may be persisted in storage. Messages published by publishers
  running in non-allowed GCP regions (or running outside of GCP
  altogether) will be routed for storage in one of the allowed regions.
  An empty list means that no regions are allowed, and is not a valid
  configuration.

  Default is `[]`.

### Extended Resource Configuration

- [**`subscription_labels`**](#var-subscription_labels): *(Optional `map(string)`)*<a name="var-subscription_labels"></a>

  A map of labels to assign to all created Pub/Sub subscriptions.

  Default is `{}`.

- [**`push_subscriptions`**](#var-push_subscriptions): *(Optional `list(push_subscription)`)*<a name="var-push_subscriptions"></a>

  The list of the push subscriptions that will be created for the PubSub
  topic.

  Default is `[]`.

  Example:

  ```hcl
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
  ```

  Each `push_subscription` object in the list accepts the following attributes:

  - [**`labels`**](#attr-push_subscriptions-labels): *(Optional `map(string)`)*<a name="attr-push_subscriptions-labels"></a>

    A set of key/value label pairs to assign to this Subscription.

  - [**`ack_deadline_seconds`**](#attr-push_subscriptions-ack_deadline_seconds): *(Optional `number`)*<a name="attr-push_subscriptions-ack_deadline_seconds"></a>

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

  - [**`message_retention_duration`**](#attr-push_subscriptions-message_retention_duration): *(Optional `string`)*<a name="attr-push_subscriptions-message_retention_duration"></a>

    How long to retain unacknowledged messages in the subscription's
    backlog, from the moment a message is published. If
    `retainAckedMessages` is `true`, then this also configures the
    retention of acknowledged messages, and thus configures how far back
    in time a `subscriptions.seek` can be done. Defaults to 7 days.
    Cannot be more than 7 days (`604800s`) or less than 10 minutes
    (`600s`). A duration in seconds with up to nine fractional digits,
    terminated by `s`.

  - [**`retain_acked_messages`**](#attr-push_subscriptions-retain_acked_messages): *(Optional `bool`)*<a name="attr-push_subscriptions-retain_acked_messages"></a>

    Indicates whether to retain acknowledged messages. If `true`, then
    messages are not expunged from the subscription's backlog, even if
    they are acknowledged, until they fall out of the
    `messageRetentionDuration` window.

  - [**`filter`**](#attr-push_subscriptions-filter): *(Optional `string`)*<a name="attr-push_subscriptions-filter"></a>

    The subscription only delivers the messages that match the filter.
    Pub/Sub automatically acknowledges the messages that don't match the
    filter. You can filter messages by their attributes. The maximum
    length of a filter is 256 bytes. After creating the subscription,
    you can't modify the filter.

  - [**`enable_message_ordering`**](#attr-push_subscriptions-enable_message_ordering): *(Optional `bool`)*<a name="attr-push_subscriptions-enable_message_ordering"></a>

    If `true`, messages published with the same `orderingKey` in
    `PubsubMessage` will be delivered to the subscribers in the order
    in which they are received by the Pub/Sub system. Otherwise, they
    may be delivered in any order.

  - [**`iam`**](#attr-push_subscriptions-iam): *(Optional `list(iam)`)*<a name="attr-push_subscriptions-iam"></a>

    List of IAM access roles to grant identities on the subscription.

    Each `iam` object in the list accepts the following attributes:

    - [**`role`**](#attr-push_subscriptions-iam-role): *(Optional `string`)*<a name="attr-push_subscriptions-iam-role"></a>

      The role that should be applied. Only one
      `google_pubsub_subscription_iam_binding` can be used per role.
      Note that custom roles must be of the format
      `[projects|organizations]/{parent-name}/roles/{role-name}`.

    - [**`members`**](#attr-push_subscriptions-iam-members): *(Optional `set(string)`)*<a name="attr-push_subscriptions-iam-members"></a>

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

      Default is `[]`.

    - [**`authoritative`**](#attr-push_subscriptions-iam-authoritative): *(Optional `bool`)*<a name="attr-push_subscriptions-iam-authoritative"></a>

      Whether to exclusively set (authoritative mode) or add
      (non-authoritative/additive mode) members to the role.

      Default is `true`.

### Module Configuration

- [**`module_enabled`**](#var-module_enabled): *(Optional `bool`)*<a name="var-module_enabled"></a>

  Specifies whether resources in the module will be created.

  Default is `true`.

- [**`module_depends_on`**](#var-module_depends_on): *(Optional `list(dependency)`)*<a name="var-module_depends_on"></a>

  A list of dependencies.
  Any object can be _assigned_ to this list to define a hidden external dependency.

  Default is `[]`.

  Example:

  ```hcl
  module_depends_on = [
    null_resource.name
  ]
  ```

## Module Outputs

The following attributes are exported in the outputs of the module:

- [**`topic`**](#output-topic): *(`object(topic)`)*<a name="output-topic"></a>

  The created pub sub resource.

- [**`push_subscriptions`**](#output-push_subscriptions): *(`list(push_subscription)`)*<a name="output-push_subscriptions"></a>

  The created push pub sub subscriptions.

- [**`pull_subscriptions`**](#output-pull_subscriptions): *(`list(pull_subscription)`)*<a name="output-pull_subscriptions"></a>

  The created pull pub sub subscriptions.

- [**`module_enabled`**](#output-module_enabled): *(`bool`)*<a name="output-module_enabled"></a>

  Whether this module is enabled.

## External Documentation

### Google  Documentation

- https://cloud.google.com/pubsub#section-1

### Terraform GPC Provider Documentation

- Topic: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic
- Topic IAM: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic_iam
- Subscription: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_subscription
- Subscription IAM: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_subscription_iam

## Module Versioning

This Module follows the principles of [Semantic Versioning (SemVer)].

Given a version number `MAJOR.MINOR.PATCH`, we increment the:

1. `MAJOR` version when we make incompatible changes,
2. `MINOR` version when we add functionality in a backwards compatible manner, and
3. `PATCH` version when we make backwards compatible bug fixes.

### Backwards compatibility in `0.0.z` and `0.y.z` version

- Backwards compatibility in versions `0.0.z` is **not guaranteed** when `z` is increased. (Initial development)
- Backwards compatibility in versions `0.y.z` is **not guaranteed** when `y` is increased. (Pre-release)

## About Mineiros

[Mineiros][homepage] is a remote-first company headquartered in Berlin, Germany
that solves development, automation and security challenges in cloud infrastructure.

Our vision is to massively reduce time and overhead for teams to manage and
deploy production-grade and secure cloud infrastructure.

We offer commercial support for all of our modules and encourage you to reach out
if you have any questions or need help. Feel free to email us at [hello@mineiros.io] or join our
[Community Slack channel][slack].

## Reporting Issues

We use GitHub [Issues] to track community reported issues and missing features.

## Contributing

Contributions are always encouraged and welcome! For the process of accepting changes, we use
[Pull Requests]. If you'd like more information, please see our [Contribution Guidelines].

## Makefile Targets

This repository comes with a handy [Makefile].
Run `make help` to see details on each available target.

## License

[![license][badge-license]][apache20]

This module is licensed under the Apache License Version 2.0, January 2004.
Please see [LICENSE] for full details.

Copyright &copy; 2020-2022 [Mineiros GmbH][homepage]


<!-- References -->

[homepage]: https://mineiros.io/?ref=terraform-google-pubsub
[hello@mineiros.io]: mailto:hello@mineiros.io
[badge-license]: https://img.shields.io/badge/license-Apache%202.0-brightgreen.svg
[releases-terraform]: https://github.com/hashicorp/terraform/releases
[releases-aws-provider]: https://github.com/terraform-providers/terraform-provider-aws/releases
[apache20]: https://opensource.org/licenses/Apache-2.0
[slack]: https://mineiros.io/slack
[terraform]: https://www.terraform.io
[aws]: https://aws.amazon.com/
[semantic versioning (semver)]: https://semver.org/
[variables.tf]: https://github.com/mineiros-io/terraform-google-pubsub/blob/main/variables.tf
[examples/]: https://github.com/mineiros-io/terraform-google-pubsub/blob/main/examples
[issues]: https://github.com/mineiros-io/terraform-google-pubsub/issues
[license]: https://github.com/mineiros-io/terraform-google-pubsub/blob/main/LICENSE
[makefile]: https://github.com/mineiros-io/terraform-google-pubsub/blob/main/Makefile
[pull requests]: https://github.com/mineiros-io/terraform-google-pubsub/pulls
[contribution guidelines]: https://github.com/mineiros-io/terraform-google-pubsub/blob/main/CONTRIBUTING.md
