terraform {
  backend "s3" {
    bucket         = "terraform-state-link-shortener"
    key            = "prod/link-shortener/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

