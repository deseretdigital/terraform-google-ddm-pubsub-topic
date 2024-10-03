output "topic_id" {
  description = "The ID of the created Pub/Sub Topic."
  value       = google_pubsub_topic.topic.id
}