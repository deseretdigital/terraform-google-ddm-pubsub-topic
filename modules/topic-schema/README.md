# Google PubSub Topic with Schema Validation

This module creates a Google PubSub Topic with schema validation to ensure messages conform to a defined structure.

## Features

- **Schema Validation**: Validate messages against AVRO, Protocol Buffer, or JSON schemas
- **Encryption at Rest**: Support for Customer-Managed Encryption Keys (CMEK)
- **Message Retention**: Configurable message retention duration
- **Regional Constraints**: Control where messages can be stored
- **Labels**: Flexible labeling for resource organization

## Usage

### Basic Configuration:

```hcl
module "pubsub_topic_with_schema" {
  source  = "deseretdigital/ddm-pubsub-topic/google//modules/topic-schema"
  version = "~> 2.0"

  # Required
  topic_name      = "my-validated-topic"
  schema          = "projects/my-project/schemas/my-schema"
  schema_encoding = "JSON"

  # Optional
  labels = {
    env = "prod"
  }

  message_retention_duration = "2678400s"
}
```

### Complete Example with AVRO Schema

```hcl
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
  }
}

provider "google" {
  project = "my-project-id"
  region  = "us-west3"
}

resource "google_pubsub_schema" "event_schema" {
  name = "event-schema"
  type = "AVRO"
  definition = jsonencode({
    type = "record"
    name = "Event"
    fields = [
      {
        name = "eventId"
        type = "string"
      },
      {
        name = "timestamp"
        type = "long"
      },
      {
        name = "userId"
        type = "string"
      }
    ]
  })
}

module "pubsub_topic_with_schema" {
  source          = "deseretdigital/ddm-pubsub-topic/google//modules/topic-schema"
  version         = "~> 2.0"
  topic_name      = "validated-events"
  schema          = google_pubsub_schema.event_schema.id
  schema_encoding = "JSON"

  labels = {
    date   = "2025-10-31"
    region = "us-west3"
    env    = "prod"
  }

  message_retention_duration = "604800s" # 7 days

  # Enable encryption at rest
  kms_key_name = "projects/my-project/locations/us-west3/keyRings/my-keyring/cryptoKeys/my-key"

  # Restrict message storage to specific regions
  message_storage_policy = {
    allowed_persistence_regions = ["us-west3", "us-west4"]
  }

  depends_on = [google_pubsub_schema.event_schema]
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3 |
| google | ~> 7.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| topic_name | Name of the topic | `string` | n/a | yes |
| schema | Schema that messages should be validated against | `string` | n/a | yes |
| schema_encoding | Encoding of messages (BINARY, JSON, ENCODING_UNSPECIFIED) | `string` | `"ENCODING_UNSPECIFIED"` | no |
| project | The project in which the resource belongs | `string` | `null` | no |
| labels | A set of key/value label pairs to assign to this Topic | `map(string)` | `{}` | no |
| message_retention_duration | Minimum duration to retain a message | `string` | `"2678400s"` | no |
| kms_key_name | Cloud KMS CryptoKey for encryption | `string` | `null` | no |
| message_storage_policy | Policy constraining where messages can be stored | `object` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| topic_id | The ID of the created Pub/Sub Topic |
| topic_name | The name of the created Pub/Sub Topic |
| effective_labels | All labels present on the resource in GCP |
| kms_key_name | The Cloud KMS CryptoKey used for encryption |
| schema_settings | Settings for validating messages against a schema |