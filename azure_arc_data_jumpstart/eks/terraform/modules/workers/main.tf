#
# EKS Worker Nodes Resources
#  * IAM role allowing Kubernetes actions to access other AWS services
#  * EKS Node Group to launch worker nodes
#

resource "aws_iam_role" "arcdemo-node" {
  name = "terraform-eks-arcdemo-node"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "arcdemo-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.arcdemo-node.name
}

resource "aws_iam_role_policy_attachment" "arcdemo-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.arcdemo-node.name
}

resource "aws_iam_role_policy_attachment" "arcdemo-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.arcdemo-node.name
}

resource "aws_eks_node_group" "arcdemo" {
  cluster_name    = var.cluster_name
  node_group_name = "arcdemo"
  node_role_arn   = aws_iam_role.arcdemo-node.arn
  subnet_ids      = var.cluster_subnet_ids
  instance_types  = ["t3.2xlarge"]
  
  scaling_config {
    desired_size = 3
    max_size     = 3
    min_size     = 3
  }

  depends_on = [
    aws_iam_role_policy_attachment.arcdemo-node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.arcdemo-node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.arcdemo-node-AmazonEC2ContainerRegistryReadOnly,
  ]
}
