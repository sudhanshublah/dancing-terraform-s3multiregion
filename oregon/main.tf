module "s3-bucket" {
  source = "../modules/s3-bucket"
  bucket_name = var.s3_bucket_name
  acl = var.acl
  
  # tags = {
  #   Terraform = "true"
  #   Environment = "test"
  # } 
}