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