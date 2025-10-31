# Google PubSub Topic

This module creates a Google PubSub Topic with support for encryption, message retention, regional constraints, and schema validation.

The primary point is to make the creation of these resources repeatable and configurable.

## Features

- **Encryption at Rest**: Support for Customer-Managed Encryption Keys (CMEK)
- **Message Retention**: Configurable message retention duration
- **Regional Constraints**: Control where messages can be stored
- **Labels**: Flexible labeling for resource organization
- **Schema Validation**: Optional schema validation through the `topic-schema` submodule

## Usage

### Basic Configuration:

```hcl
module "pubsub_topic_module" {
  source  = "deseretdigital/ddm-pubsub-topic/google"
  version = "~> 2.0"

  # Required
  topic_name = "my-topic"

  # Optional
  labels = {
    env    = "prod"
    region = "us-west3"
  }

  message_retention_duration = "2678400s"
}
```

### Example with Encryption and Regional Constraints

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

module "pubsub_topic_secure" {
  source     = "deseretdigital/ddm-pubsub-topic/google"
  version    = "~> 2.0"
  topic_name = "secure-topic"

  labels = {
    date   = "2025-10-31"
    region = "us-west3"
    env    = "prod"
  }

  message_retention_duration = "604800s" # 7 days

  # Enable encryption at rest with CMEK
  kms_key_name = "projects/my-project/locations/us-west3/keyRings/my-keyring/cryptoKeys/my-key"

  # Restrict message storage to specific regions
  message_storage_policy = {
    allowed_persistence_regions = ["us-west3", "us-west4"]
  }
}
```

### Example with Schema Validation

For topics that require schema validation, use the `topic-schema` submodule:

```hcl
resource "google_pubsub_schema" "example" {
  name = "example-schema"
  type = "AVRO"
  definition = jsonencode({
    type = "record"
    name = "Avro"
    fields = [
      {
        name = "StringField"
        type = "string"
      },
      {
        name = "IntField"
        type = "int"
      }
    ]
  })
}

module "pubsub_topic_with_schema" {
  source          = "deseretdigital/ddm-pubsub-topic/google//modules/topic-schema"
  version         = "~> 2.0"
  topic_name      = "validated-topic"
  schema          = google_pubsub_schema.example.id
  schema_encoding = "JSON"

  labels = {
    env = "prod"
  }

  depends_on = [google_pubsub_schema.example]
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