# Google PubSub Topic

This module creates a Google PubSub Topic.

The primary point is to make the creation of these resources repeatable.

## Usage

### Basic Configuration:

```hcl
module "pubsub_topic_module" {
  source  = "deseretdigital/ddm-pubsub-topic/google"
  version = "~> 1.0.0"

  # Required
  topic_name = {YOUR_TOPIC_NAME}

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
      source = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}

provider "google" {
  # Configuration options
}

module "pubsub_topic_module" {
  source  = "deseretdigital/ddm-pubsub-topic/google"
  version = "~> 1.0.0"
  topic_name = "Example_TopicName"

  labels = {
    date   = "2024-10-11"
    region = "us-west3"
    env    = "prod"
  }

  message_retention_duration = "84000s"
}
```