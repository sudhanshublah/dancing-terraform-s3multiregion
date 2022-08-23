module "s3-bucket" {
  source = "../modules/s3-bucket"
  bucket_name = "${var.s3_bucket_name}-California"
  acl = var.acl
  
  # tags = {
  #   Terraform = "true"
  #   Environment = "test"
  # } 
}

module "kms-key" {
  source = "../modules/kms"
}