terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.5.0"
    }
  }
}

provider "google" {
  project = "experimental-sandbox-445216"
  region  = "us-central1"
}

data "google_project" "project" {}

# Test Schema
resource "google_pubsub_schema" "test_schema" {
  name       = "test-event-schema-v1"
  type       = "PROTOCOL_BUFFER"
  definition = <<EOF
syntax = "proto3";
message TestEvent {
  string id = 1;
  string message = 2;
  int64 timestamp = 3;
}
EOF
}

# Test BigQuery Dataset
resource "google_bigquery_dataset" "test_events" {
  dataset_id  = "test_events"
  location    = "US"
  description = "Test dataset for topic module"
}

# Test BigQuery Table
resource "google_bigquery_table" "test_event" {
  dataset_id          = google_bigquery_dataset.test_events.dataset_id
  table_id            = "test_event"
  deletion_protection = false

  schema = jsonencode([
    { name = "id", type = "STRING", mode = "NULLABLE" },
    { name = "message", type = "STRING", mode = "NULLABLE" },
    { name = "timestamp", type = "TIMESTAMP", mode = "NULLABLE" }
  ])

  time_partitioning {
    type  = "DAY"
    field = "timestamp"
  }
}

# Test Topic with BigQuery Streaming
module "test_topic" {
  source = "../modules/topic-schema"

  topic_name      = "Test_Event"
  schema          = "projects/${data.google_project.project.project_id}/schemas/${google_pubsub_schema.test_schema.name}"
  schema_encoding = "BINARY"

  labels = {
    env     = "test"
    purpose = "module-testing"
  }

  # Enable BigQuery streaming
  bigquery_table = "${data.google_project.project.project_id}.${google_bigquery_dataset.test_events.dataset_id}.${google_bigquery_table.test_event.table_id}"
  project_number = data.google_project.project.number

  depends_on = [
    google_pubsub_schema.test_schema,
    google_bigquery_table.test_event
  ]
}

# Outputs
output "topic_id" {
  value = module.test_topic.topic_id
}

output "bigquery_subscription_id" {
  value = module.test_topic.bigquery_subscription_id
}

output "dead_letter_topic_id" {
  value = module.test_topic.dead_letter_topic_id
}
