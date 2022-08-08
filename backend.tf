terraform {
  backend "gcs" {
    bucket  = "arm-gcs-test-bucket"
    prefix  = "terraform/state"
 }
}

