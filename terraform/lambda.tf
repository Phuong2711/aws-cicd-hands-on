# =====================================================================
# LAMBDA FUNCTION
# Terraform chỉ tạo "khung" function lần đầu với code placeholder.
# Code thật + layer sẽ do GitHub Actions cập nhật mỗi lần push.
# =====================================================================

locals {
  function_name = "${var.project_name}-fn"
  layer_name    = "${var.project_name}-deps"
}

# Zip placeholder từ src/ để Lambda có code khởi tạo (bắt buộc khi tạo function)
data "archive_file" "placeholder" {
  type        = "zip"
  source_dir  = "${path.module}/../src"
  output_path = "${path.module}/.build/placeholder.zip"
  excludes    = ["__pycache__", "requirements.txt"]
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${local.function_name}"
  retention_in_days = 7
}

resource "aws_lambda_function" "this" {
  function_name = local.function_name
  description   = "Demo Lambda deploy bằng GitHub Actions"
  role          = aws_iam_role.lambda_exec.arn
  runtime       = var.lambda_runtime
  handler       = var.lambda_handler
  architectures = ["x86_64"]
  timeout       = 10
  memory_size   = 128

  filename         = data.archive_file.placeholder.output_path
  source_code_hash = data.archive_file.placeholder.output_base64sha256

  environment {
    variables = {
      LOG_LEVEL = "INFO"
    }
  }

  # QUAN TRỌNG: code, hash và layers sẽ do CI/CD thay đổi.
  # Nếu không ignore, lần `terraform apply` sau sẽ revert về placeholder.
  lifecycle {
    ignore_changes = [
      filename,
      source_code_hash,
      layers,
      description,
    ]
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic_logs,
    aws_cloudwatch_log_group.lambda,
  ]
}
