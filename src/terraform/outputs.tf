locals {
    aws_iam_openid_connect_provider_extract_from_arn = element(split("oidc-provider/", aws_iam_openid_connect_provider.eks_oidc.arn), 1)
}

output "aws_iam_openid_connect_provider_arn" {
    description = "AWS IAM OIDC provider ARN"
    value = local.aws_iam_openid_connect_provider_extract_from_arn
}