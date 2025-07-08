resource "kubernetes_config_map" "aws_auth" {
    metadata {
      name = "aws-auth"
      namespace = "kube-system"
    }

    data = {
        mapRoles = yamlencode([
        {
        rolearn  = "arn:aws:iam::123456789012:role/eks-node-role"
        username = "system:node:{{EC2PrivateDNSName}}"
        groups   = ["system:bootstrappers", "system:nodes"]
        }
      ])
    }

    depends_on = [ aws_eks_cluster.eks_dev_cluster, aws_eks_node_group.eks_dev_ng ]
}