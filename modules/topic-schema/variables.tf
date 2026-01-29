variable "project" {
  description = "The project in which the resource belongs. If it is not provided, the provider project is used."
  type        = string
  default     = null
}

variable "labels" {
  description = "A set of key/value label pairs to assign to this Topic."
  type        = map(string)
  default     = {}
}

variable "message_retention_duration" {
  default     = "2678400s"
  description = "Indicates the minimum duration to retain a message after it is published to the topic. If this field is set, messages published to the topic in the last messageRetentionDuration are always available to subscribers. For instance, it allows any attached subscription to seek to a timestamp that is up to messageRetentionDuration in the past. If this field is not set, message retention is controlled by settings on individual subscriptions."
  type        = string

  validation {
    condition     = can(regex("^\\d+s$", var.message_retention_duration))
    error_message = "Value must be a duration represented in seconds. Example: 86400s"
  }
}

variable "kms_key_name" {
  description = "The resource name of the Cloud KMS CryptoKey to be used to protect access to messages published on this topic. Format: projects/{project}/locations/{location}/keyRings/{keyRing}/cryptoKeys/{cryptoKey}"
  type        = string
  default     = null
}

variable "message_storage_policy" {
  description = "Policy constraining the set of Google Cloud Platform regions where messages published to the topic may be stored. If not set, messages may be stored in any region."
  type = object({
    allowed_persistence_regions = list(string)
  })
  default = null
}

variable "schema" {
  description = "The name of the schema that messages published should be validated against. Format is projects/{project}/schemas/{schema}. The value of this field will be deleted-schema if the schema has been deleted."
  type        = string

  validation {
    condition     = can(regex("^projects/[^/]+/schemas/[^/]+$", var.schema))
    error_message = "Value must be in the format projects/{project}/schemas/{schema}."
  }
}

variable "schema_encoding" {
  description = "The encoding of the messages validated against schema. Only JSON is supported. If this is not set, the encoding will be defaulted to JSON."
  type        = string
  default     = "ENCODING_UNSPECIFIED"

  validation {
    condition     = contains(["BINARY", "JSON", "ENCODING_UNSPECIFIED"], var.schema_encoding)
    error_message = "Value must be one of: BINARY, JSON, ENCODING_UNSPECIFIED"
  }
}

variable "topic_name" {
  description = "Name of the topic."
  type        = string
}

# BigQuery Streaming Configuration (Optional)
# When bigquery_table is set, a BigQuery subscription with dead letter queue is automatically created

variable "bigquery_table" {
  description = "The BigQuery table to stream messages to. Format: {projectId}.{datasetId}.{tableId}. If set, creates a BigQuery subscription with dead letter queue."
  type        = string
  default     = null

  validation {
    condition     = var.bigquery_table == null || can(regex("^[^\\.]+\\.[^\\.]+\\.[^\\.]+$", var.bigquery_table))
    error_message = "Value must be a valid BigQuery table name in format: {projectId}.{datasetId}.{tableId}"
  }
}

variable "bigquery_use_topic_schema" {
  description = "When true, use the topic's schema as the columns to write to in BigQuery."
  type        = bool
  default     = true
}

variable "bigquery_subscription_labels" {
  description = "Labels for the BigQuery subscription and dead letter resources. If not set, uses the topic labels."
  type        = map(string)
  default     = null
}

variable "project_number" {
  description = "The GCP project number. Required when bigquery_table is set. Used to construct the Pub/Sub service account for IAM permissions."
  type        = string
  default     = null

  validation {
    condition     = var.project_number == null || can(regex("^\\d+$", var.project_number))
    error_message = "Value must be a valid GCP project number (digits only)."
  }
}

variable "max_delivery_attempts" {
  description = "Maximum delivery attempts before sending to dead letter queue. Must be between 5 and 100."
  type        = number
  default     = 10

  validation {
    condition     = var.max_delivery_attempts >= 5 && var.max_delivery_attempts <= 100
    error_message = "Value must be between 5 and 100."
  }
}
