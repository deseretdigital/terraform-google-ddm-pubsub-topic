terraform {
  required_version = ">= 1.3"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.5.0, < 8.0.0"
    }
    github = {
      source  = "integrations/github"
      version = ">= 5.0.0, < 7.0.0"
    }
  }
}