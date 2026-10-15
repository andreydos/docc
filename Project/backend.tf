terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket-andr-928001001-final"
    key            = "final/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks-final"
    encrypt        = true
  }
}
