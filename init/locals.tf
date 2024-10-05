locals {
  providers = {
    aws = {
      region = "us-east-1"
    }

    default_tags = {
      Environment = "Init"
    }
  }
}
