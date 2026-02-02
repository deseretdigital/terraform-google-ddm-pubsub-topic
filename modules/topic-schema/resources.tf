# ==============================================================================
# Schema Resources - fetched from ddm-protobuf and created in GCP
# ==============================================================================

locals {
  schema_name = "${lower(replace(var.topic_name, "_", "-"))}-schema-${var.schema_config.version}"
}

# Fetch the Pub/Sub schema from ddm-protobuf
data "github_repository_file" "pubsub_schema" {
  repository = "ddm-protobuf"
  branch     = "main"
  file       = var.schema_config.path
}

# Create the Pub/Sub schema in GCP
resource "google_pubsub_schema" "schema" {
  name       = local.schema_name
  project    = var.project
  type       = "PROTOCOL_BUFFER"
  definition = data.github_repository_file.pubsub_schema.content
}

# ==============================================================================
# Topic Resource
# ==============================================================================

resource "google_pubsub_topic" "topic" {
  name    = var.topic_name
  project = var.project
  labels  = var.labels

  schema_settings {
    schema   = google_pubsub_schema.schema.id
    encoding = var.schema_config.encoding
  }

  message_retention_duration = var.message_retention_duration
  kms_key_name               = var.kms_key_name

  dynamic "message_storage_policy" {
    for_each = var.message_storage_policy != null ? [var.message_storage_policy] : []
    content {
      allowed_persistence_regions = message_storage_policy.value.allowed_persistence_regions
    }
  }

  depends_on = [google_pubsub_schema.schema]
}

# ==============================================================================
# BigQuery Streaming Resources (created when bigquery_config is set)
# ==============================================================================

locals {
  bigquery_enabled       = var.bigquery_config != null
  subscription_labels    = var.bigquery_subscription_labels != null ? var.bigquery_subscription_labels : var.labels
  subscription_name      = "${var.topic_name}_BigQuery"
  dead_letter_name       = "${var.topic_name}_DeadLetter"
  pubsub_service_account = var.project_number != null ? "service-${var.project_number}@gcp-sa-pubsub.iam.gserviceaccount.com" : null
  bigquery_table_ref     = local.bigquery_enabled ? "${google_pubsub_topic.topic.project}.${var.bigquery_config.dataset_id}.${var.bigquery_config.table_id}" : null
}

# Fetch the BigQuery schema from ddm-protobuf
data "github_repository_file" "bigquery_schema" {
  count      = local.bigquery_enabled ? 1 : 0
  repository = "ddm-protobuf"
  branch     = "main"
  file       = var.bigquery_config.schema_path
}

# BigQuery Dataset
resource "google_bigquery_dataset" "dataset" {
  count       = local.bigquery_enabled ? 1 : 0
  dataset_id  = var.bigquery_config.dataset_id
  project     = google_pubsub_topic.topic.project
  location    = var.bigquery_config.dataset_location
  labels      = local.subscription_labels
  description = "Dataset for ${var.topic_name} Pub/Sub events"
}

# BigQuery Table
resource "google_bigquery_table" "table" {
  count               = local.bigquery_enabled ? 1 : 0
  dataset_id          = google_bigquery_dataset.dataset[0].dataset_id
  table_id            = var.bigquery_config.table_id
  project             = google_pubsub_topic.topic.project
  labels              = local.subscription_labels
  schema              = data.github_repository_file.bigquery_schema[0].content
  deletion_protection = false

  dynamic "time_partitioning" {
    for_each = var.bigquery_config.partition_field != null ? [1] : []
    content {
      type  = "DAY"
      field = var.bigquery_config.partition_field
    }
  }

  clustering = length(var.bigquery_config.clustering_fields) > 0 ? var.bigquery_config.clustering_fields : null
}

# BigQuery Subscription - streams messages directly to BigQuery
resource "google_pubsub_subscription" "bigquery" {
  count  = local.bigquery_enabled ? 1 : 0
  name   = local.subscription_name
  topic  = google_pubsub_topic.topic.id
  labels = local.subscription_labels

  bigquery_config {
    use_topic_schema = var.bigquery_use_topic_schema
    table            = local.bigquery_table_ref
  }

  dead_letter_policy {
    dead_letter_topic     = google_pubsub_topic.dead_letter[0].id
    max_delivery_attempts = var.max_delivery_attempts
  }

  depends_on = [
    google_bigquery_table.table,
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
  member  = "serviceAccount:${local.pubsub_service_account}"
}

# IAM: Allow Pub/Sub to acknowledge messages from main subscription
resource "google_pubsub_subscription_iam_member" "bigquery_subscriber" {
  count        = local.bigquery_enabled ? 1 : 0
  subscription = google_pubsub_subscription.bigquery[0].id
  role         = "roles/pubsub.subscriber"
  member       = "serviceAccount:${local.pubsub_service_account}"
}

# IAM: Allow Pub/Sub to read BigQuery table metadata
resource "google_project_iam_member" "bigquery_metadata_viewer" {
  count   = local.bigquery_enabled ? 1 : 0
  project = google_pubsub_topic.topic.project
  role    = "roles/bigquery.metadataViewer"
  member  = "serviceAccount:${local.pubsub_service_account}"
}

# IAM: Allow Pub/Sub to write to BigQuery table
resource "google_project_iam_member" "bigquery_data_editor" {
  count   = local.bigquery_enabled ? 1 : 0
  project = google_pubsub_topic.topic.project
  role    = "roles/bigquery.dataEditor"
  member  = "serviceAccount:${local.pubsub_service_account}"
}
