terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket-andr-928001001-lesson89"
    key            = "lesson-8-9/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks-lesson89"
    encrypt        = true
  }
}
