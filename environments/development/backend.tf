terraform {
  backend "s3" {
    region         = "us-east-1"
    bucket         = "ammarlakis-tfstate"
    key            = "development"
    dynamodb_table = "terraform-state-lock"
  }
}
