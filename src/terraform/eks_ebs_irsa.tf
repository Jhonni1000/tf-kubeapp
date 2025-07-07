resource "aws_iam_role" "eks_ebs_irsa" {
    name = "ebs-csi-iam-role"
    assume_role_policy = jsonencode({
        Version = "2012-01-17"
        Statement = [{
            Effect = "Allow"
            Action = "sts:AssumeRoleWithWebIdentity"
            Principal = {
                Federated = aws_iam_openid_connect_provider.eks_oidc.arn
            }
            Condition = {
                StringEquals = {
                    "${replace(aws_iam_openid_connect_provider.eks_oidc.url, "https://", "")}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
                }
            }
        }]
    })
}

resource "aws_iam_role_policy_attachment" "eks_ebs_irsa_policy" {
    role = aws_iam_role.eks_ebs_irsa.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

