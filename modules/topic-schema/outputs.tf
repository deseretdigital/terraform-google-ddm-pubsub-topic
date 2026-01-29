output "topic_id" {
  description = "The ID of the created Pub/Sub Topic."
  value       = google_pubsub_topic.topic.id
}

output "topic_name" {
  description = "The name of the created Pub/Sub Topic."
  value       = google_pubsub_topic.topic.name
}

output "effective_labels" {
  description = "All labels (key/value pairs) present on the resource in GCP, including the labels configured through Terraform and those configured by GCP."
  value       = google_pubsub_topic.topic.effective_labels
}

output "kms_key_name" {
  description = "The resource name of the Cloud KMS CryptoKey used to protect access to messages published on this topic."
  value       = google_pubsub_topic.topic.kms_key_name
}

output "schema_settings" {
  description = "Settings for validating messages published against a schema."
  value       = google_pubsub_topic.topic.schema_settings
}

# ==============================================================================
# BigQuery Streaming Outputs (only populated when bigquery_table is set)
# ==============================================================================

output "bigquery_subscription_id" {
  description = "The ID of the BigQuery subscription. Null if BigQuery streaming is not enabled."
  value       = length(google_pubsub_subscription.bigquery) > 0 ? google_pubsub_subscription.bigquery[0].id : null
}

output "bigquery_subscription_name" {
  description = "The name of the BigQuery subscription. Null if BigQuery streaming is not enabled."
  value       = length(google_pubsub_subscription.bigquery) > 0 ? google_pubsub_subscription.bigquery[0].name : null
}

output "dead_letter_topic_id" {
  description = "The ID of the dead letter topic. Null if BigQuery streaming is not enabled."
  value       = length(google_pubsub_topic.dead_letter) > 0 ? google_pubsub_topic.dead_letter[0].id : null
}

output "dead_letter_topic_name" {
  description = "The name of the dead letter topic. Null if BigQuery streaming is not enabled."
  value       = length(google_pubsub_topic.dead_letter) > 0 ? google_pubsub_topic.dead_letter[0].name : null
}

output "dead_letter_subscription_id" {
  description = "The ID of the dead letter subscription. Null if BigQuery streaming is not enabled."
  value       = length(google_pubsub_subscription.dead_letter) > 0 ? google_pubsub_subscription.dead_letter[0].id : null
}

output "dead_letter_subscription_name" {
  description = "The name of the dead letter subscription. Null if BigQuery streaming is not enabled."
  value       = length(google_pubsub_subscription.dead_letter) > 0 ? google_pubsub_subscription.dead_letter[0].name : null
}