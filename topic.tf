resource "google_pubsub_topic" "topic" {
  count = var.module_enabled ? 1 : 0

  project = var.project
  name    = var.topic_name

  labels = var.topic_labels

  kms_key_name = var.kms_key_name

  dynamic "message_storage_policy" {
    for_each = var.allowed_persistence_regions != null ? [1] : []

    content {
      allowed_persistence_regions = var.allowed_persistence_regions
    }
  }

  depends_on = [var.module_depends_on]
}

# a list of iam members to allow publishing to this topic..
resource "google_pubsub_topic_iam_member" "publisher" {
  for_each = var.module_enabled ? var.publish_iam_members : []

  project = var.project

  topic = google_pubsub_topic.topic[0].id

  role = "roles/pubsub.publisher"

  member = each.value

  depends_on = [
    google_pubsub_topic.topic,
    var.module_depends_on,
  ]
}
