terraform {
  required_version = ">= 1.8.4"
}

provider "aws" {
  region = var.region
}
