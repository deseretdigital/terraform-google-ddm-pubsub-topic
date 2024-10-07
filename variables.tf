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

variable "topic_name" {
  description = "Name of the topic."
  type        = string
}