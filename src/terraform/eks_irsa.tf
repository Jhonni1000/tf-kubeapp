resource "aws_iam_openid_connect_provider" "eks_oidc" {
    client_id_list = ["sts.amazonaws.com"]
    thumbprint_list = [data.tls_certificate.oidc_thumbprint.certificates[0].sha1_fingerprint]
    url = aws_eks_cluster.eks_dev_cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_role" "eks_irsa_iam_role" {
    name = "eks_irsa_iam_role"
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
                    "${replace(aws_iam_openid_connect_provider.eks_oidc.url, "https://", "")}:sub" = "system:serviceaccount:default:irsa-demo-sa"

                }
            }
        }]
    })
}

resource "aws_iam_role_policy_attachment" "eks_irsa_iam_role_policy" {
    role = aws_iam_role.eks_irsa_iam_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}