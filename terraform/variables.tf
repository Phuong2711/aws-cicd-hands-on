variable "aws_region" {
  description = "Region deploy Lambda"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Tên project, dùng làm prefix cho resource"
  type        = string
  default     = "aws-cicd-hands-on"
}

variable "lambda_runtime" {
  description = "Runtime của Lambda. Phải khớp với PYTHON_VERSION trong workflow."
  type        = string
  default     = "python3.12"
}

variable "lambda_handler" {
  description = "Entry point: <file>.<function>"
  type        = string
  default     = "handler.lambda_handler"
}

variable "github_org" {
  description = "GitHub user/org sở hữu repo (vd: Phuong2711)"
  type        = string
}

variable "github_repo" {
  description = "Tên repo trên GitHub (vd: aws-cicd-hands-on)"
  type        = string
}

variable "github_branch" {
  description = "Branch được phép deploy qua OIDC"
  type        = string
  default     = "main"
}

variable "create_github_oidc_provider" {
  description = "Đặt false nếu tài khoản AWS đã có OIDC provider cho token.actions.githubusercontent.com"
  type        = bool
  default     = true
}
