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