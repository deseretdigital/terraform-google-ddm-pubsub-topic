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
