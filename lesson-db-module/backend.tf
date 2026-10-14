terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket-andr-928001001-lessondb"
    key            = "lesson-db-module/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks-lessondb"
    encrypt        = true
  }
}
