terraform {
  required_version = ">= 1.3"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.5.0, < 8.0.0"
    }
  }
}