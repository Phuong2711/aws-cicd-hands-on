output "lambda_function_name" {
  description = "Set vào GitHub repo variable LAMBDA_FUNCTION_NAME"
  value       = aws_lambda_function.this.function_name
}

output "lambda_layer_name" {
  description = "Set vào GitHub repo variable LAMBDA_LAYER_NAME"
  value       = local.layer_name
}

output "aws_region" {
  description = "Set vào GitHub repo variable AWS_REGION"
  value       = var.aws_region
}

output "github_deploy_role_arn" {
  description = "Set vào GitHub repo secret AWS_ROLE_ARN"
  value       = aws_iam_role.github_deploy.arn
}

output "lambda_exec_role_arn" {
  value = aws_iam_role.lambda_exec.arn
}
