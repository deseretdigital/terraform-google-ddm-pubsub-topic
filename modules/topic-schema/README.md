# Google PubSub Topic with Schema

This module creates a Google PubSub Topic with a provided schema.

## Usage

### Basic Configuration:

```hcl
module "pubsub_topic_module" {
  source  = "deseretdigital/ddm-pubsub-topic/google"
  version = "~> 1.0.0"

  # Required
  topic_name      = {YOUR_TOPIC_NAME}
  schema          = {YOUR_SCHEMA}
  schema_encoding = {SCHEMA_ENCODING}

  # Optional
  labels = {
    env    = "prod"
    region = {REGION}
    # etc...
  }

  message_retention_duration = {DEFAULT_2678400s}
}
```

This module creates a Google PubSub Topic. 

#### Example Usage

```hcl
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}

provider "google" {
  # Configuration options
}

resource "google_pubsub_schema" "example" {
  name = "example"
  type = "AVRO"
  definition = "{\n  \"type\" : \"record\",\n  \"name\" : \"Avro\",\n  \"fields\" : [\n    {\n      \"name\" : \"StringField\",\n      \"type\" : \"string\"\n    },\n    {\n      \"name\" : \"IntField\",\n      \"type\" : \"int\"\n    }\n  ]\n}\n"
}

module "pubsub_topic_module" {
  source          = "deseretdigital/ddm-pubsub-topic/google"
  version         = "~> 1.0.0"
  topic_name      = "Example_TopicName"
  schema          = "projects/{PROJECT_NAME}/schemas/example"
  schema_encoding = "JSON"

  labels = {
    date   = "2024-10-11"
    region = "us-west3"
    env    = "prod"
  }

  message_retention_duration = "84000s"

  depends_on = [google_pubsub_schema.example]
}
```