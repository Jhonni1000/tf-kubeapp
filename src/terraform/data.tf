data "aws_partition" "current" {}

data "tls_certificate" "oidc_thumbprint" {
    url = aws_eks_cluster.eks_dev_cluster.identity[0].oidc[0].issuer
}