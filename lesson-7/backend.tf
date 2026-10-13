terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket-andr-928001001-lesson7" # Назва S3-бакета
    key            = "lesson-7/terraform.tfstate"                     # Шлях до файлу стейту
    region         = "us-west-2"                                      # Регіон AWS
    dynamodb_table = "terraform-locks-lesson7"                        # Назва таблиці DynamoDB
    encrypt        = true                                             # Шифрування файлу стейту
  }
}
