[<img src="https://raw.githubusercontent.com/mineiros-io/brand/3bffd30e8bdbbde32c143e2650b2faa55f1df3ea/mineiros-primary-logo.svg" width="400"/>][homepage]

[![Terraform Version][badge-terraform]][releases-terraform]
[![Google Provider Version][badge-tf-gcp]][releases-google-provider]
[![Join Slack][badge-slack]][slack]

# terraform-google-pubsub-module

A [Terraform] module for [Google Cloud Platform (GCP)][gcp].

**_This module supports Terraform version 1
and is compatible with the Terraform Google Provider version 3._**

This module is part of our Infrastructure as Code (IaC) framework
that enables our users and customers to easily deploy and manage reusable,
secure, and production-grade cloud infrastructure.

- [Module Features](#module-features)
- [Getting Started](#getting-started)
- [Module Argument Reference](#module-argument-reference)
  - [Top-level Arguments](#top-level-arguments)
    - [Module Configuration](#module-configuration)
    - [Main Resource Configuration](#main-resource-configuration)
    - [Extended Resource Configuration](#extended-resource-configuration)
- [Module Attributes Reference](#module-attributes-reference)
- [External Documentation](#external-documentation)
- [Module Versioning](#module-versioning)
  - [Backwards compatibility in `0.0.z` and `0.y.z` version](#backwards-compatibility-in-00z-and-0yz-version)
- [About Mineiros](#about-mineiros)
- [Reporting Issues](#reporting-issues)
- [Contributing](#contributing)
- [Makefile Targets](#makefile-targets)
- [License](#license)

## Module Features

In contrast to the plain `terraform_google_pubsub` resource this module has better features.
While all security features can be disabled as needed best practices
are pre-configured.

## Getting Started

Most basic usage just setting required arguments:

```hcl
module "terraform-google-pubsub" {
  source = "github.com/mineiros-io/terraform-google-pubsub.git?ref=v0.1.0"
}
```

## Module Argument Reference

See [variables.tf] and [examples/] for details and use-cases.

### Top-level Arguments

#### Module Configuration

- **`module_enabled`**: _(Optional `bool`)_

  Specifies whether resources in the module will be created.
  Default is `true`.

- **`module_depends_on`**: _(Optional `list(dependencies)`)_

  A list of dependencies. Any object can be _assigned_ to this list to define a hidden external dependency.

  Example:
  ```hcl
  module_depends_on = [
    google_network.network
  ]
  ```

#### Main Resource Configuration

- **`topic_name`**: **_(Required `string`)_**

  The name of the Pub/Sub topic.

- **`region`**: **_(Required `string`)_**

  The region to host the VPC and all related resources in.

- **`project`**: **_(Required `string`)_**

  The ID of the project in which the resources belong.

- **`topic_labels`**: _(Optional `map(string)`)_

  A map of labels to assign to the Pub/Sub topic.
  Default is `{}`.

  Each `topic_labels` object can have the following fields:

  - **`CreatedAt`**: _(Optional `string`)_

    The Date of topic_label creation.

  - **`tag`**: _(Optional `string`)_

    A tag describing the topic_label.

  Example
  ```hcl
  topic_labels = {
    CreatedAt   = "2021-03-31"
    tag         = "some description"
  }
  ```

- **`subscription_labels`**: _(Optional `map(string)`)_

  A map of labels to assign to all created Pub/Sub subscriptions.
  Default is `{}`.

  Each `user` object can have the following fields:

  - **`CreatedAt`**: _(Optional `string`)_

    The Date of subscription_label creation.


  - **`tag`**: _(Optional `string`)_

    A tag describing the subscription_label.

  Example
  ```hcl
  topic_labels = {
    CreatedAt   = "2021-03-31"
    tag         = "some description"
  }
  ```

- **`kms_key_name`**: _(Optional `string`)_

  The resource name of the Cloud KMS CryptoKey to be used to protect access to messages published on this topic. Default is `null`.

- **`default_service_account`**: _(Optional `string`)_

  If set, the service account will be used for all subscriptions. Otherwise, the module will look for a service account to be set in each subscription and use the PubSubs default service account if none is provided.Default is `null`.

- **`publish_iam_members`**: _(Optional `set(string)`)_

  A list of iam members to gran publish access to the topic
  Default is `null`.

- **`allowed_persistence_regions`**: _(Optional `set(string)`)_

  A list of persistence regions. Default inherits from organization's Resource Location Restriction policy. Default is `{}`.

- **`grant_token_creator`**: _(Optional `bool`)_

  Specify true if you want to add token creator role to the default Pub/Sub SA.
  Default is `true`.

- **`push_subscriptions`**: _(Optional `any`)_

  The list of the push subscriptions that will be created for the PubSub topic.
  Default is `[]`.

  A `push_subscriptions` object can have the following fields:

  - **`name`**: **_(Required `string`)_**

    The Name of the user.

  - **`description`**: _(Optional `decription`)_

    A description describing the user in more detail.
    Default is "".

  Example
  ```hcl
  user = {
    name        = "marius"
    description = "The guy from Berlin."
  }
  ```

- **`pull_subscriptions`**: _(Optional `any`)_

  The list of the push subscriptions that will be created for the PubSub topic.
  Default is `[]`.

  A `pull_subscriptions` object can have the following fields:

  - **`name`**: **_(Required `string`)_**

    The Name of the user.

  - **`description`**: _(Optional `decription`)_

    A description describing the user in more detail.
    Default is "".

  Example
  ```hcl
  user = {
    name        = "marius"
    description = "The guy from Berlin."
  }
  ```


#### Extended Resource Configuration

## Module Attributes Reference

The following attributes are exported in the outputs of the module:

- **`module_enabled`**

  Whether this module is enabled.

- **`topic`**

  All outputs of the created `pubsub` resource.

- **`push_subscriptions`**

  All outputs of the created `push_pubsub_subscriptions` resource.

- **`pull_subscriptions`**

  All outputs of the created `pull_pubsub_subscriptions` resource.

## External Documentation

- Google Documentation:
  - Pubsub: https://cloud.google.com/pubsub/docs
  - Pubsub topic: https://cloud.google.com/pubsub/docs/admin
  - Pubsub subscriber: https://cloud.google.com/pubsub/docs/subscriber
  - Push subscription: https://cloud.google.com/pubsub/docs/push
  - Pull subscription: https://cloud.google.com/pubsub/docs/pull

- Terraform Google Provider Documentation:
  - https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_subscription
  - https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic

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

<!--
[![license][badge-license]][apache20]

This module is licensed under the Apache License Version 2.0, January 2004.
Please see [LICENSE] for full details.
-->
Copyright &copy; 2020-2021 [Mineiros GmbH][homepage]


<!-- References -->

[homepage]: https://mineiros.io/?ref=terraform-pubsub
[hello@mineiros.io]: mailto:hello@mineiros.io

<!-- markdown-link-check-disable -->

[badge-build]: https://github.com/mineiros-io/terraform-google-pubsub/workflows/Tests/badge.svg

<!-- markdown-link-check-enable -->

[badge-semver]: https://img.shields.io/github/v/tag/mineiros-io/terraform-google-pubsub.svg?label=latest&sort=semver
[badge-license]: https://img.shields.io/badge/license-Apache%202.0-brightgreen.svg
[badge-terraform]: https://img.shields.io/badge/Terraform-1.x-623CE4.svg?logo=terraform
[badge-slack]: https://img.shields.io/badge/slack-@mineiros--community-f32752.svg?logo=slack

<!-- markdown-link-check-disable -->

[build-status]: https://github.com/mineiros-io/terraform-google-pubsub/actions
[releases-github]: https://github.com/mineiros-io/terraform-google-pubsub/releases

<!-- markdown-link-check-enable -->

[releases-terraform]: https://github.com/hashicorp/terraform/releases
[badge-tf-gcp]: https://img.shields.io/badge/google-3.x-1A73E8.svg?logo=terraform
[releases-google-provider]: https://github.com/terraform-providers/terraform-provider-google/releases
[apache20]: https://opensource.org/licenses/Apache-2.0
[slack]: https://mineiros.io/slack
[terraform]: https://www.terraform.io
[gcp]: https://cloud.google.com/
[semantic versioning (semver)]: https://semver.org/

<!-- markdown-link-check-disable -->

[variables.tf]: https://github.com/mineiros-io/terraform-google-pubsub/blob/main/variables.tf
[examples/]: https://github.com/mineiros-io/terraform-google-pubsub/blob/main/examples
[issues]: https://github.com/mineiros-io/terraform-google-pubsub/issues
[license]: https://github.com/mineiros-io/terraform-google-pubsub/blob/main/LICENSE
[makefile]: https://github.com/mineiros-io/terraform-google-pubsub/blob/main/Makefile
[pull requests]: https://github.com/mineiros-io/terraform-google-pubsub/pulls
[contribution guidelines]: https://github.com/mineiros-io/terraform-google-pubsub/blob/main/CONTRIBUTING.md

<!-- markdown-link-check-enable -->
