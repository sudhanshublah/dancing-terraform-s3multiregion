# data "aws_iam_role" "n" {
  
# }

# resource "aws_kms_key" "this" {
#   description              = var.description
#   customer_master_key_spec = var.key_spec
#   is_enabled               = var.enabled
#   enable_key_rotation      = var.rotation_enabled
#   tags                     = var.tags
#   policy                   = var.policy
# #   deletion_window_in_days  = 30
# }

# # # Add an alias to the key
# # resource "aws_kms_alias" "this" {
# #   name          = "alias/${var.alias}"
# #   target_key_id = aws_kms_key.this.key_id
# # }

# resource "aws_kms_grant" "a" {
#   name              = "my-grant"
#   key_id            = aws_kms_key.this.key_id
#   grantee_principal = data.aws_iam_role.n.arn
#   operations        = ["Encrypt", "Decrypt", "GenerateDataKey"]

#   constraints {
#     encryption_context_equals = {
#       Department = "Finance"
#     }
#   }
# }



resource "aws_kms_key" "my_kms_key" {
  description              = "My KMS Keys for Data Encryption"
  customer_master_key_spec = var.key_spec
  is_enabled               = var.enabled
  enable_key_rotation      = var.rotation_enabled  

  tags = {
    Name = "my_kms_key"
  }

  policy = <<EOF
{
    "Id": "key-consolepolicy-3",
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Enable IAM User Permissions",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::459743668989:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        },
        {
            "Sid": "Allow access for Key Administrators",
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                    "arn:aws:iam::459743668989:role/aws-service-role/cks.kms.amazonaws.com/AWSServiceRoleForKeyManagementServiceCustomKeyStores",
                    "arn:aws:iam::459743668989:user/kms-user"
                ]
            },
            "Action": [
                "kms:Create*",
                "kms:Describe*",
                "kms:Enable*",
                "kms:List*",
                "kms:Put*",
                "kms:Update*",
                "kms:Revoke*",
                "kms:Disable*",
                "kms:Get*",
                "kms:Delete*",
                "kms:TagResource",
                "kms:UntagResource",
                "kms:ScheduleKeyDeletion",
                "kms:CancelKeyDeletion"
            ],
            "Resource": "*"
        },
        {
            "Sid": "Allow use of the key",
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                    "arn:aws:iam::459743668989:role/aws-service-role/cks.kms.amazonaws.com/AWSServiceRoleForKeyManagementServiceCustomKeyStores",
                    "arn:aws:iam::459743668989:user/kms-user"
                ]
            },
            "Action": [
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:DescribeKey"
            ],
            "Resource": "*"
        },
        {
            "Sid": "Allow attachment of persistent resources",
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                    "arn:aws:iam::459743668989:role/aws-service-role/cks.kms.amazonaws.com/AWSServiceRoleForKeyManagementServiceCustomKeyStores",
                    "arn:aws:iam::459743668989:user/kms-user"
                ]
            },
            "Action": [
                "kms:CreateGrant",
                "kms:ListGrants",
                "kms:RevokeGrant"
            ],
            "Resource": "*",
            "Condition": {
                "Bool": {
                    "kms:GrantIsForAWSResource": "true"
                }
            }
        }
    ]
}
EOF
}

resource "aws_kms_alias" "my_kms_alias" {
  target_key_id = aws_kms_key.my_kms_key.key_id
  name          = "alias/${var.kms_alias}"
}

output "key_id" {
  value = aws_kms_key.my_kms_key.key_id
}