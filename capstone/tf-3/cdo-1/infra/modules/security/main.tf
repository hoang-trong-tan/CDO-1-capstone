# TODO(INFRA-3): implement theo docs/03_security_design.md §1.2 (Security Groups)
# và §4.1 (KMS key). Tên PHẢI đúng theo infra/CLAUDE.md mục 1 — không tự đặt tên khác.
#
# Security Group cần có:
# - sg-alb-internal       : inbound 443 từ Internal Alert Relay/VPN, outbound 8443 -> sg-eks-workload
# - sg-eks-workload       : inbound 8443 từ sg-alb-internal, outbound 443 VPC endpoint + 5432 sg-rds
# - sg-eks-control-plane  : inbound 443 từ node/admin role, outbound 10250 đến node
# - sg-rds                : inbound 5432 chỉ từ sg-eks-workload
# - sg-vpc-endpoint       : inbound 443 từ sg-eks-workload + sg-eks-control-plane
#
# KMS key (customer-managed, bật automatic rotation) cần có:
# - alias/cdo-audit-kms, alias/cdo-app-data-kms, alias/cdo-secrets-kms,
#   alias/cdo-infra-kms, alias/cdo-observability-kms

# Cost tracking: mọi resource hỗ trợ tag PHẢI dùng `tags = local.module_tags`
# (xem tags.tf) — không dùng var.tags trực tiếp, để Cost Explorer group theo Component.

# Security Module - thêm vào main.tf
resource "aws_kms_key" "cdo_observability_kms" {
  description             = "KMS key for observability logs encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  tags                    = local.module_tags

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM policies"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow CloudWatch Logs"
        Effect = "Allow"
        Principal = {
          Service = "logs.${data.aws_region.current.name}.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:CreateGrant",
          "kms:DescribeKey"
        ]
        Resource = "*"
        Condition = {
          ArnLike = {
            "kms:EncryptionContext:aws:logs:arn" = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
          }
        }
      }
    ]
  })
}

resource "aws_kms_alias" "cdo_observability_kms" {
  name          = "alias/cdo-observability-kms"
  target_key_id = aws_kms_key.cdo_observability_kms.key_id
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
