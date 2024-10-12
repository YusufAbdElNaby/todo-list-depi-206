provider "aws" {
  region     = "eu-west-3"

}

# No need to reference VPC.tf explicitly
# Terraform will automatically load both Main.tf and VPC.tf