resource "aws_iam_openid_connect_provider" "eks_oidc" {
    client_id_list = ["sts.amazonaws.com"]
    thumbprint_list = [data.tls_certificate.oidc_thumbprint.certificates[0].sha1_fingerprint]
    url = aws_eks_cluster.eks_dev_cluster.identity[0].oidc[0].issuer
}