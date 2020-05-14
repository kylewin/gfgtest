provider "aws" {
  region = "us-west-2"
}

module "gfginfra" {
  source            = "./module/gfgappinfra"
  postgres_password = var.postgres_password
}
