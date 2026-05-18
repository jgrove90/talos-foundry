# terraform {
#   required_version = ">= 1.0"

#   backend "s3" {
#     # Configure S3 backend for production
#     # bucket = "your-terraform-state-bucket"
#     # key    = "talos-foundry/prod/terraform.tfstate"
#     # region = "us-west-2"
#   }
# }
terraform {
  required_version = ">= 1.0"

  backend "local" {
    path = "terraform.tfstate"
  }
}