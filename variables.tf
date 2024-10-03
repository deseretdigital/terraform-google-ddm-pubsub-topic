variable "labels" {
  description = "A set of key/value label pairs to assign to this Topic."
  type        = map(string)
}

variable "message_retention_duration" {
  default     = null
  description = "Indicates the minimum duration to retain a message after it is published to the topic. If this field is set, messages published to the topic in the last messageRetentionDuration are always available to subscribers. For instance, it allows any attached subscription to seek to a timestamp that is up to messageRetentionDuration in the past. If this field is not set, message retention is controlled by settings on individual subscriptions."
  type        = string

  validation {
    condition     = can(regex("^\\d+s$", var.message_retention_duration))
    error_message = "Value must be a duration represented in seconds. Example: 86400s"
  }
}

variable "schema" {
  description = "The name of the schema that messages published should be validated against."
  type        = string

  validation {
    condition     = can(regex("projects/[^/]+/schemas/[^/]+", var.schema))
    error_message = "value must be in the format projects/{project}/schemas/{schema}"
  }
}

variable "schema_encoding" {
  description = "The encoding of messages validated against schema. Default value is ENCODING_UNSPECIFIED. Possible values are: ENCODING_UNSPECIFIED, JSON, BINARY."
  type        = string

  validation {
    condition     = contains(["BINARY", "JSON", "ENCODING_UNSPECIFIED"], var.schema_encoding)
    error_message = "Value must be one of: BINARY, JSON, ENCODING_UNSPECIFIED"
  }
}

variable "topic_name" {
  description = "Name of the topic."
  type        = string
}