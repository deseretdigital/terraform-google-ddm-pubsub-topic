# Data source for project information (used for IAM when BigQuery streaming is enabled)
data "google_project" "project" {
  count = var.bigquery_table != null ? 1 : 0
}
