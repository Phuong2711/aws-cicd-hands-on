# =====================================================================
# IAM ROLE CHO GITHUB ACTIONS (deploy role) - dùng OIDC, không cần access key
#
# Luồng:
#   GitHub Actions job  --(JWT token từ token.actions.githubusercontent.com)-->
#   AWS STS AssumeRoleWithWebIdentity --> trả về credentials tạm (1 giờ)
#   --> job dùng credentials đó gọi `aws lambda update-function-code ...`
# =====================================================================

data "aws_caller_identity" "current" {}

# Provider OIDC: nói với AWS "hãy tin token do GitHub phát hành"
resource "aws_iam_openid_connect_provider" "github" {
  count = var.create_github_oidc_provider ? 1 : 0

  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]

  # Thumbprint của GitHub; AWS hiện tự verify bằng root CA nhưng field vẫn bắt buộc.
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd",
  ]
}

locals {
  github_oidc_provider_arn = (
    var.create_github_oidc_provider
    ? aws_iam_openid_connect_provider.github[0].arn
    : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
  )
}

# Trust policy: CHỈ repo này, CHỈ branch này mới được assume role
data "aws_iam_policy_document" "github_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [local.github_oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_org}/${var.github_repo}:ref:refs/heads/${var.github_branch}"]
    }
  }
}

resource "aws_iam_role" "github_deploy" {
  name               = "${var.project_name}-github-deploy"
  assume_role_policy = data.aws_iam_policy_document.github_assume_role.json
}

# Permission policy: least privilege - chỉ đụng đúng function + layer này
data "aws_iam_policy_document" "github_deploy" {
  statement {
    sid = "UpdateLambdaCodeAndConfig"
    actions = [
      "lambda:GetFunction",
      "lambda:GetFunctionConfiguration",
      "lambda:UpdateFunctionCode",
      "lambda:UpdateFunctionConfiguration",
      "lambda:InvokeFunction",
    ]
    resources = [aws_lambda_function.this.arn]
  }

  statement {
    sid = "ManageLayer"
    actions = [
      "lambda:PublishLayerVersion",
      "lambda:ListLayerVersions",
      "lambda:GetLayerVersion",
    ]
    resources = [
      "arn:aws:lambda:${var.aws_region}:${data.aws_caller_identity.current.account_id}:layer:${local.layer_name}",
      "arn:aws:lambda:${var.aws_region}:${data.aws_caller_identity.current.account_id}:layer:${local.layer_name}:*",
    ]
  }
}

resource "aws_iam_role_policy" "github_deploy" {
  name   = "lambda-deploy"
  role   = aws_iam_role.github_deploy.id
  policy = data.aws_iam_policy_document.github_deploy.json
}
