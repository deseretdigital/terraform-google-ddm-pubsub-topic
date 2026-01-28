resource "google_pubsub_topic" "topic" {
  name    = var.topic_name
  project = var.project
  labels  = var.labels

  schema_settings {
    schema   = var.schema
    encoding = var.schema_encoding
  }

  message_retention_duration = var.message_retention_duration
  kms_key_name               = var.kms_key_name

  dynamic "message_storage_policy" {
    for_each = var.message_storage_policy != null ? [var.message_storage_policy] : []
    content {
      allowed_persistence_regions = message_storage_policy.value.allowed_persistence_regions
    }
  }
}

# ==============================================================================
# BigQuery Streaming Resources (created when bigquery_table is set)
# ==============================================================================

locals {
  bigquery_enabled    = var.bigquery_table != null
  subscription_labels = var.bigquery_subscription_labels != null ? var.bigquery_subscription_labels : var.labels
  subscription_name   = "${var.topic_name}_BigQuery"
  dead_letter_name    = "${var.topic_name}_DeadLetter"
}

# BigQuery Subscription - streams messages directly to BigQuery
resource "google_pubsub_subscription" "bigquery" {
  count  = local.bigquery_enabled ? 1 : 0
  name   = local.subscription_name
  topic  = google_pubsub_topic.topic.id
  labels = local.subscription_labels

  bigquery_config {
    use_topic_schema = var.bigquery_use_topic_schema
    table            = var.bigquery_table
  }

  dead_letter_policy {
    dead_letter_topic     = google_pubsub_topic.dead_letter[0].id
    max_delivery_attempts = var.max_delivery_attempts
  }

  depends_on = [
    google_pubsub_topic_iam_member.dead_letter_publisher,
    google_project_iam_member.bigquery_metadata_viewer,
    google_project_iam_member.bigquery_data_editor
  ]
}

# Dead Letter Queue Topic - receives failed messages
resource "google_pubsub_topic" "dead_letter" {
  count   = local.bigquery_enabled ? 1 : 0
  name    = local.dead_letter_name
  project = var.project
  labels  = local.subscription_labels
}

# Dead Letter Queue Subscription - allows consuming failed messages
resource "google_pubsub_subscription" "dead_letter" {
  count  = local.bigquery_enabled ? 1 : 0
  name   = local.dead_letter_name
  topic  = google_pubsub_topic.dead_letter[0].id
  labels = local.subscription_labels
}

# ==============================================================================
# IAM Permissions for BigQuery Streaming
# ==============================================================================

# IAM: Allow Pub/Sub to publish to DLQ
resource "google_pubsub_topic_iam_member" "dead_letter_publisher" {
  count   = local.bigquery_enabled ? 1 : 0
  project = google_pubsub_topic.dead_letter[0].project
  topic   = google_pubsub_topic.dead_letter[0].id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${var.pubsub_service_account}"
}

# IAM: Allow Pub/Sub to acknowledge messages from main subscription
resource "google_pubsub_subscription_iam_member" "bigquery_subscriber" {
  count        = local.bigquery_enabled ? 1 : 0
  subscription = google_pubsub_subscription.bigquery[0].id
  role         = "roles/pubsub.subscriber"
  member       = "serviceAccount:${var.pubsub_service_account}"
}

# IAM: Allow Pub/Sub to read BigQuery table metadata
resource "google_project_iam_member" "bigquery_metadata_viewer" {
  count   = local.bigquery_enabled ? 1 : 0
  project = google_pubsub_topic.topic.project
  role    = "roles/bigquery.metadataViewer"
  member  = "serviceAccount:${var.pubsub_service_account}"
}

# IAM: Allow Pub/Sub to write to BigQuery table
resource "google_project_iam_member" "bigquery_data_editor" {
  count   = local.bigquery_enabled ? 1 : 0
  project = google_pubsub_topic.topic.project
  role    = "roles/bigquery.dataEditor"
  member  = "serviceAccount:${var.pubsub_service_account}"
}
