resource "null_resource" "test_ci" {
  triggers = {
    always_run = timestamp()
    region     = var.aws_region
  }

  provisioner "local-exec" {
    command = "echo 'Terraform CI/CD Pipeline chạy thành công cho thư mục infra1 tại region: ${var.aws_region}'"
  }
}
