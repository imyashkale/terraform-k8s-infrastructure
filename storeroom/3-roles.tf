locals {
  name                            = ""
  oidc_provider_arn               = data.terraform_remote_state.eks.outputs.aws_iam_openid_connect_provider_arn
  oidc_provider_arn_extracted_arn = data.terraform_remote_state.eks.outputs.aws_iam_openid_connect_provider_extract_from_arn
}

resource "aws_iam_role" "irsa_iam_role" {
  name = "${local.name}-irsa-iam-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Federated = "${local.oidc_provider_arn}"
        }
        Condition = {
          StringEquals = {
            "${local.oidc_provider_arn_extracted_arn}:sub" : "system:serviceaccount:default:irsa-demo-sa"
          }
        }

      },
    ]
  })

  tags = {
    tag-key = "${local.name}-irsa-iam-role"
  }
}

# Associate IAM Role and Policy
resource "aws_iam_role_policy_attachment" "irsa_iam_role_policy_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  role       = aws_iam_role.irsa_iam_role.name
}

output "irsa_iam_role_arn" {
  description = "IRSA IAM Role ARN"
  value       = aws_iam_role.irsa_iam_role.arn
}


