resource "aws_iam_policy" "eks_lbc_irsa_policy" {
    name = "eks_lbc_irsa_policy"
    path = "/"
    policy = file("${path.module}/aws_lb_controller_iam_policy.json")
}

resource "aws_iam_role" "ebs-lbc-iam-role" {
    name = "eks-lbc-irsa-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow"
            Action = "sts:AssumeRoleWithWebIdentity"
            Principal = {
                Federated = aws_iam_openid_connect_provider.eks_oidc.arn
            }
            Condition = {
                StringEquals = {
                    "${replace(aws_iam_openid_connect_provider.eks_oidc.url, "https://", "")}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
                }
            }
        }]
    })
}

resource "aws_iam_role_policy_attachment" "eks_lbc_irsa_policy" {
    role = aws_iam_role.ebs-lbc-iam-role.name
    policy_arn = aws_iam_policy.eks_lbc_irsa_policy.arn
}
