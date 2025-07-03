provider "kubernetes" {
  # Configure this with your kubeconfig or other auth methods
  config_path = "~/.kube/config"
}

resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = <<EOT
- rolearn: arn:aws:iam::738605694254:role/eks_nodegroup_role
  username: system:node:{{EC2PrivateDNSName}}
  groups:
    - system:bootstrappers
    - system:nodes

- rolearn: arn:aws:iam::738605694254:role/GithubRoleFor-tf-kubeapp
  username: github-actions
  groups:
    - system:masters
EOT

    mapUsers = <<EOT
- userarn: arn:aws:iam::738605694254:user/eks_user
  username: eks_user
  groups:
    - system:masters
EOT
  }
}
