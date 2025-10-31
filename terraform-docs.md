## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 7.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | ~> 7.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_pubsub_topic.topic](https://registry.terraform.io/providers/hashicorp/google/7.0/docs/resources/pubsub_topic) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_labels"></a> [labels](#input\_labels) | A set of key/value label pairs to assign to this Topic. | `map(string)` | `{}` | no |
| <a name="input_message_retention_duration"></a> [message\_retention\_duration](#input\_message\_retention\_duration) | Indicates the minimum duration to retain a message after it is published to the topic. If this field is set, messages published to the topic in the last messageRetentionDuration are always available to subscribers. For instance, it allows any attached subscription to seek to a timestamp that is up to messageRetentionDuration in the past. If this field is not set, message retention is controlled by settings on individual subscriptions. | `string` | `"2678400s"` | no |
| <a name="input_topic_name"></a> [topic\_name](#input\_topic\_name) | Name of the topic. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_topic_id"></a> [topic\_id](#output\_topic\_id) | The ID of the created Pub/Sub Topic. |
| <a name="output_topic_name"></a> [topic\_name](#output\_topic\_name) | The name of the created Pub/Sub Topic. |