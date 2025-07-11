resource "aws_iam_role" "eks_cluster_role" {
  name = "eks_cluster_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_role_policy" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  ])
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = each.value
}

resource "aws_iam_role" "eks_nodegroup_role" {
  name = "eks_nodegroup_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_nodegroup_role_policy" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AutoScalingFullAccess"
  ])
  role       = aws_iam_role.eks_nodegroup_role.name
  policy_arn = each.value
}


resource "aws_eks_cluster" "eks_dev_cluster" {
  name     = "eks_dev_cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = "1.31"

  vpc_config {
    subnet_ids              = module.vpc.private_subnets
    endpoint_private_access = false
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  tags = {
    Environment = "dev"
    Managed_by  = "OPAKI"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_role_policy,
    module.vpc
  ]
}


resource "aws_eks_node_group" "eks_public_dev_ng" {
  cluster_name = aws_eks_cluster.eks_dev_cluster.name

  node_group_name = "eks_dev_ng"
  node_role_arn   = aws_iam_role.eks_nodegroup_role.arn
  subnet_ids      = module.vpc.public_subnets

  ami_type       = "AL2_x86_64"
  capacity_type  = "ON_DEMAND"
  disk_size      = 20
  instance_types = ["t3.medium"]

  remote_access {
    ec2_ssh_key = "testkey"
  }

  scaling_config {
    desired_size = 1
    min_size     = 1
    max_size     = 2
  }

  update_config {
    max_unavailable = 1
  }

  tags = {
    Environment = "dev"
    Managed_by  = "OPAKI"
    Name = "Public-Node-Group"
    "k8s.io/cluster-autoscaler/${aws_eks_cluster.eks_dev_cluster.name}" = "owned"
    "k8s.io/cluster-autoscaler/enabled" = "true"

  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_nodegroup_role_policy,
    aws_eks_cluster.eks_dev_cluster
  ]
}


/*
resource "aws_eks_node_group" "eks_private_dev_ng" {
  cluster_name = aws_eks_cluster.eks_dev_cluster.name

  node_group_name = "eks_dev_ng"
  node_role_arn   = aws_iam_role.eks_nodegroup_role.arn
  subnet_ids      = module.vpc.private_subnets

  ami_type       = "AL2_x86_64"
  capacity_type  = "ON_DEMAND"
  disk_size      = 20
  instance_types = ["t3.medium"]

  remote_access {
    ec2_ssh_key = "testkey"
  }

  scaling_config {
    desired_size = 1
    min_size     = 1
    max_size     = 2
  }

  update_config {
    max_unavailable = 1
  }

  tags = {
    Environment = "dev"
    Managed_by  = "OPAKI"
    Name = "Private-Node-Group"
    "k8s.io/cluster-autoscaler/${aws_eks_cluster.eks_dev_cluster.name}" = "owned"
    "k8s.io/cluster-autoscaler/enabled" = "TRUE"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_nodegroup_role_policy,
    aws_eks_cluster.eks_dev_cluster
  ]
}
*/