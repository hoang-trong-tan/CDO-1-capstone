output "state_bucket_name" {
  description = "Copy giá trị này vào environments/sandbox/foundation/backend.tf sau khi apply"
  value       = aws_s3_bucket.state.id
}

output "state_lock_table_name" {
  description = "DynamoDB table cho Terraform state lock (KHÔNG phải tf-3-aiops-idempotency-lock)"
  value       = aws_dynamodb_table.state_lock.id
}

output "github_oidc_role_arn" {
  description = "IAM Role ARN cho GitHub Actions assume qua OIDC — gán vào GitHub repo secret AWS_ROLE_ARN"
  value       = aws_iam_role.github_actions.arn
}

output "state_kms_key_arn" {
  description = "KMS Key ARN dùng mã hóa state bucket — cần truyền vào backend.tf nếu dùng kms_key_id"
  value       = aws_kms_key.state.arn
}

output "github_oidc_provider_arn" {
  description = "OIDC Provider ARN của GitHub Actions — tham khảo khi tạo thêm role CI"
  value       = aws_iam_openid_connect_provider.github.arn
}
