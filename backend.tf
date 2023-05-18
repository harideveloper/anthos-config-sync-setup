terraform {
  backend "gcs" {
    bucket  = "acm-gcs-test-bucket"
    prefix  = "terraform/state"
 }
}

