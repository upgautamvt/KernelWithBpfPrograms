# Define Terraform configuration requirements and providers
terraform {
  required_version = ">= 1.9.2"

  required_providers {
    random = {
      source  = "hashicorp/random"
      # version = "~> 3.6.1" # Allows any version >= 3.6.1 and < 3.7.0
      version = "~> 3.6.1" # Use the latest patch version of 3.6.x
    }
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.7.6" # Use the latest patch version of 0.7.x
    }
  }

  # Optional: Configure backend for state storage
  # backend "s3" {
  #   bucket         = "my-tf-state"
  #   key            = "terraform/state"
  #   region         = "us-east-1"
  # }
}
