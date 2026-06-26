# INFRA-1: Bootstrap — State Backend + GitHub Actions OIDC
# Theo docs/04_deployment_design.md §1.1 và §1.3
# Không phụ thuộc module nào khác — apply đầu tiên bằng local backend.
#
# SAU KHI apply xong, copy output vào environments/sandbox/foundation/backend.tf

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# ─────────────────────────────────────────────
# 1. KMS KEY — mã hóa Terraform state bucket
#    Riêng biệt với 5 KMS key của app (security module)
# ─────────────────────────────────────────────

resource "aws_kms_key" "state" {
  description             = "KMS key for Terraform state bucket — ${var.name_prefix}-sandbox"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  # KMS key policy: root account có full access để delegate xuống IAM.
  # Quyền cụ thể (GenerateDataKey, Decrypt) cho GitHub Actions role
  # được delegate qua IAM identity-based policy (aws_iam_role_policy.github_actions_tfstate).
  # Không reference ARN của role ở đây để tránh circular dependency
  # (KMS key được tạo trước role).
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowRootFullAccess"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      }
    ]
  })

  tags = local.module_tags
}

resource "aws_kms_alias" "state" {
  name          = "alias/${var.name_prefix}-sandbox-state-kms"
  target_key_id = aws_kms_key.state.key_id
}

# ─────────────────────────────────────────────
# 2. S3 BUCKET — Terraform state storage
#    Naming: tf3-cdo1-sandbox-tfstate
#    Theo CLAUDE.md §4: tf3-cdo1-sandbox-<component>
# ─────────────────────────────────────────────

resource "aws_s3_bucket" "state" {
  # Tên bucket phải globally unique — thêm account id để tránh conflict
  bucket = "${var.name_prefix}-sandbox-tfstate-${data.aws_caller_identity.current.account_id}"

  # Bảo vệ khỏi xóa nhầm (state bucket là critical)
  lifecycle {
    prevent_destroy = true
  }

  tags = local.module_tags
}

resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.state.arn
    }
    bucket_key_enabled = true # giảm chi phí KMS API call
  }
}

resource "aws_s3_bucket_public_access_block" "state" {
  bucket = aws_s3_bucket.state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# DenyInsecureTransport — theo docs/03_security_design.md §4.2
resource "aws_s3_bucket_policy" "state_deny_http" {
  bucket = aws_s3_bucket.state.id

  # aws_s3_bucket_public_access_block phải được tạo trước khi gắn policy
  depends_on = [aws_s3_bucket_public_access_block.state]

  # Bucket policy chỉ chứa DenyInsecureTransport.
  # Quyền S3 cho GitHub Actions được cấp qua IAM identity-based policy
  # (aws_iam_role_policy.github_actions_tfstate) — không cần Allow ở đây
  # vì IAM role policy + bucket policy cùng allow là đủ theo AWS evaluation logic.
  # Không reference role ARN ở bucket policy để tránh circular dependency.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyInsecureTransport"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.state.arn,
          "${aws_s3_bucket.state.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}

# ─────────────────────────────────────────────
# 3. DYNAMODB TABLE — Terraform state lock
#    KHÔNG nhầm với tf-3-aiops-idempotency-lock (app)
#    Theo CLAUDE.md §1: bảng app lock đặt tên riêng
# ─────────────────────────────────────────────

resource "aws_dynamodb_table" "state_lock" {
  name         = "${var.name_prefix}-sandbox-tfstate-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID" # Terraform yêu cầu đúng tên này

  attribute {
    name = "LockID"
    type = "S"
  }

  # Mã hóa bằng KMS state key — theo docs/03_security_design.md §4.1
  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.state.arn
  }

  tags = local.module_tags
}

# ─────────────────────────────────────────────
# 4. GITHUB ACTIONS OIDC
#    Theo docs/04_deployment_design.md §1.1:
#    "CI authentication: GitHub Actions OIDC"
#    Theo docs/04_deployment_design.md §6:
#    "GitHub Actions dùng OIDC"
# ─────────────────────────────────────────────

# Thumbprint list cho token.actions.githubusercontent.com
# Giá trị cố định từ GitHub documentation — không tự tính
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = ["sts.amazonaws.com"]

  # Thumbprint của GitHub Actions OIDC certificate (cố định, GitHub quản lý)
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd"
  ]

  tags = local.module_tags
}

# ─────────────────────────────────────────────
# 4a. IAM Role cho GitHub Actions
#     Least-privilege theo từng pipeline stage
#     (docs/04_deployment_design.md §2.1 Pipeline stages)
# ─────────────────────────────────────────────

resource "aws_iam_role" "github_actions" {
  name        = "${var.name_prefix}-sandbox-github-actions"
  description = "Assumed by GitHub Actions via OIDC — ${var.github_repo}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowGitHubOIDC"
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringLike = {
            # Cho phép mọi branch/tag/PR trong repo này
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_repo}:*"
          }
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = local.module_tags
}

# ─────────────────────────────────────────────
# 4b. Inline policy — Terraform state operations
#     Stage: Terraform Plan / Apply (docs §2.1)
# ─────────────────────────────────────────────

resource "aws_iam_role_policy" "github_actions_tfstate" {
  name = "tfstate-access"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3StateAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:GetBucketVersioning",
          "s3:GetEncryptionConfiguration"
        ]
        Resource = [
          aws_s3_bucket.state.arn,
          "${aws_s3_bucket.state.arn}/*"
        ]
      },
      {
        Sid    = "DynamoDBStateLock"
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:DescribeTable"
        ]
        Resource = aws_dynamodb_table.state_lock.arn
      },
      {
        Sid    = "KMSStateDecrypt"
        Effect = "Allow"
        Action = [
          "kms:GenerateDataKey",
          "kms:Decrypt",
          "kms:DescribeKey"
        ]
        Resource = aws_kms_key.state.arn
      }
    ]
  })
}

# ─────────────────────────────────────────────
# 4c. Inline policy — ECR Push
#     Stage: Publish (docs §2.1 "Push image theo SHA")
# ─────────────────────────────────────────────

resource "aws_iam_role_policy" "github_actions_ecr" {
  name = "ecr-push"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ECRAuthToken"
        Effect = "Allow"
        Action = ["ecr:GetAuthorizationToken"]
        # GetAuthorizationToken tidak mendukung resource-level permission
        Resource = "*"
      },
      {
        Sid    = "ECRPushToOwnedRepos"
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:DescribeRepositories",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        # Scope ECR access chỉ repo tf-3 prefix
        Resource = "arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:repository/tf-3-*"
      }
    ]
  })
}

# ─────────────────────────────────────────────
# 4d. Inline policy — EKS Describe
#     Stage: Smoke test (docs §2.1)
#     Và Terraform plan/apply cần describe cluster để config provider
# ─────────────────────────────────────────────

resource "aws_iam_role_policy" "github_actions_eks" {
  name = "eks-describe"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EKSDescribeCluster"
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters"
        ]
        Resource = "arn:aws:eks:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:cluster/${var.name_prefix}-sandbox-*"
      }
    ]
  })
}

# ─────────────────────────────────────────────
# 4e. Inline policy — Terraform plan: read-only AWS resources
#     Cho phép CI chạy plan mà không cần quyền apply rộng
#     (docs §2.1: "Lint / Test / Scan / Plan" stage)
# ─────────────────────────────────────────────

resource "aws_iam_role_policy" "github_actions_tf_readonly" {
  name = "terraform-readonly"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ReadOnlyForTerraformPlan"
        Effect = "Allow"
        Action = [
          # IAM read (để Terraform compare state)
          "iam:GetRole",
          "iam:GetRolePolicy",
          "iam:ListRolePolicies",
          "iam:ListAttachedRolePolicies",
          "iam:GetOpenIDConnectProvider",
          "iam:ListOpenIDConnectProviders",
          # KMS read
          "kms:DescribeKey",
          "kms:ListAliases",
          # VPC / Networking read
          "ec2:DescribeVpcs",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeRouteTables",
          "ec2:DescribeVpcEndpoints",
          # DynamoDB read (app tables — read only)
          "dynamodb:DescribeTable",
          "dynamodb:ListTables"
        ]
        Resource = "*"
      }
    ]
  })
}
