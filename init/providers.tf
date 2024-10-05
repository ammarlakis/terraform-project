provider "aws" {
  region = local.providers.aws.region

  default_tags {
    tags = local.providers.default_tags
  }
}
