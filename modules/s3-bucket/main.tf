data "aws_kms_key" "my-kms-key" {
  name = "my_kms_key"
}

locals {
  bucket = [var.bucket_name]
}

resource "aws_s3_bucket" "Bucket" {
  for_each = local.bucket
  bucket = each.key
  acl = var.acl
  # region = "us-east-1"



  server_side_encryption_configuration {
    rule {
      bucket_key_enabled = true

      apply_server_side_encryption_by_default {
          kms_master_key_id = data.aws_kms_key.my-kms-key.arn
          sse_algorithm     = "aws:kms"
        }
      }
  }
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.example.id
  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_cors_configuration" "example" {
  bucket = aws_s3_bucket.Bucket.id

  cors_rule {
    allowed_headers = ["Authorization"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    expose_headers = []
    max_age_seconds = 3000
  }
  
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET","PUT", "POST","HEAD"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }

}

resource "aws_iam_role" "my-replication-role" {
  name = "my-replication-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "my-replication-policy" {
  name = "my-replication-policy"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetReplicationConfiguration",
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.bucket.arn}"
      ]
    },
    {
      "Action": [
        "s3:GetObjectVersion",
        "s3:GetObjectVersionAcl"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.bucket.arn}/*"
      ]
    },
    {
      "Action": [
        "s3:ReplicateObject",
        "s3:ReplicateDelete"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.destination.arn}/*"
    }
  ]
}
POLICY
}

resource "aws_iam_policy_attachment" "attach-policy" {
  role = aws_iam_role.my-replication-role.name
  policy_arn = aws_iam_policy.my-replication-policy.arn
}

# resource "aws_s3_bucket_replication_configuration" "one_to_two" {
#   # Must have bucket versioning enabled first
#   depends_on = [aws_s3_bucket_versioning.east]

#   role   = aws_iam_role.east_replication.arn
#   bucket = aws_s3_bucket.east.id

#   rule {
#     id = "foobar"

#     filter {
#       prefix = "foo"
#     }

#     status = "Enabled"

#     destination {
#       bucket        = aws_s3_bucket.west.arn
#       storage_class = "STANDARD"
#     }
#   }

#   # depends_on =  []
# }

# resource "aws_s3_bucket_replication_configuration" "one_to_three" {
#   # Must have bucket versioning enabled first
#   depends_on = [aws_s3_bucket_versioning.west]

#   role   = aws_iam_role.west_replication.arn
#   bucket = aws_s3_bucket.west.id

#   rule {
#     id = "foobar"

#     filter {
#       prefix = "foo"
#     }

#     status = "Enabled"

#     destination {
#       bucket        = aws_s3_bucket.east.arn
#       storage_class = "STANDARD"
#     }
#   }
# }

