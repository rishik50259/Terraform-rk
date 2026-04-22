# ---------------------------------------------
# Terraform Backend Configuration
# Purpose: Defines where Terraform stores its state file
# Instead of storing state locally, this uses AWS S3 for:
# - Centralized state management
# - Team collaboration
# - Better reliability and durability
#
# ---------------------------------------------
terraform {
  backend "s3" {

    # -----------------------------------------
    # S3 Bucket Name
    # Purpose: Specifies the S3 bucket used to store the Terraform state file
    # This bucket must already exist before running Terraform
    # -----------------------------------------
    bucket = "nexflixterraformbe01"

    # -----------------------------------------
    # State File Path (Key)
    # Purpose: Defines the location/name of the state file inside the bucket
    # Helps organize state files per environment (e.g., dev, prod)
    # -----------------------------------------
    key = "dev/terraform.tfstate" # for dev env
	#key = "stage/terraform.tfstate" # for stage env. Uncomment it when creating dev env
	#key = "prod/terraform.tfstate" # for stage env. Uncomment it when creating prod env

    # -----------------------------------------
    # AWS Region for Backend
    # Purpose: Specifies the region where the S3 bucket is hosted
    # Must match the actual region of the bucket
    # -----------------------------------------
    region = "ap-south-1"
	
	dynamodb_table = "terraform-locks"
  }
}