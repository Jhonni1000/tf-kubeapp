provider "kubernetes" {
  host                   = aws_eks_cluster.eks_dev_cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.eks_dev_cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

data "aws_eks_cluster_auth" "eks" {
  name = aws_eks_cluster.eks_dev_cluster.name
}

resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = yamlencode([
      {
        rolearn  = aws_iam_role.eks_nodegroup_role.arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups   = [
          "system:bootstrappers",
          "system:nodes"
        ]
      }
    ])
    mapUsers = yamlencode([
      {
        userarn  = "arn:aws:iam::738605694254:user/test-user"
        username = "test-user"
        groups   = [
          "system:masters"
        ]
      },
      {
        userarn  = "arn:aws:iam::738605694254:root"
        username = "root"
        groups   = [
          "system:masters"
        ]
      }
    ])
  }

  depends_on = [aws_eks_node_group.eks_dev_ng]
}
