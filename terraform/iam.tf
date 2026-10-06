# =====================================================================
# IAM ROLE CHO LAMBDA (execution role)
# Đây là role mà Lambda "đội" khi chạy. Nó quyết định Lambda được gọi
# dịch vụ AWS nào. Ở đây chỉ cần ghi log CloudWatch.
# =====================================================================

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_exec" {
  name               = "${var.project_name}-lambda-exec"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

# Quyền ghi log: logs:CreateLogGroup, CreateLogStream, PutLogEvents
resource "aws_iam_role_policy_attachment" "lambda_basic_logs" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
