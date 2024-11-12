terraform {
  required_version = ">= 1.9.0"
  required_providers {
    minio = {
      source = "aminueza/minio"
      version = "3.2.1"
    }
  }
}