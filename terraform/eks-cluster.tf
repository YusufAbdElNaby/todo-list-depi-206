

provider "kubernetes" {
 # load_config_file        = false
  host                    = data.aws_eks_cluster.DevOps-DEPI-206-eks-cluster.endpoint
  token                   = data.aws_eks_cluster_auth.DevOps-DEPI-206-eks-cluster.token
  cluster_ca_certificate  = base64decode(data.aws_eks_cluster.DevOps-DEPI-206-eks-cluster.certificate_authority[0].data)
}

# Data source for EKS cluster details
data "aws_eks_cluster" "DevOps-DEPI-206-eks-cluster" {
  name = "DevOps-DEPI-206-eks-cluster"
}

# Data source for EKS authentication details
data "aws_eks_cluster_auth" "DevOps-DEPI-206-eks-cluster" {
  name = data.aws_eks_cluster.DevOps-DEPI-206-eks-cluster.name
}

# EKS cluster module
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.24.3"

  cluster_name    = "DevOps-DEPI-206-eks-cluster"
  cluster_version = "1.31"

  # Specify VPC and Subnets
  vpc_id     = aws_vpc.main.id
  subnet_ids = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id, aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id]

  # Enable IAM roles for service accounts (IRSA)
  enable_irsa = true

  # Worker node group configuration
  eks_managed_node_groups = {
    eks_nodes = {
      desired_capacity = 1
      max_capacity     = 2
      min_capacity     = 1

      instance_type = "t3.medium"
      ami_type = "AL2_x86_64"  # For Amazon Linux 2
      key_name      = var.key_name  # Your SSH key for worker nodes

      # Disk size for worker nodes
      disk_size = 20
    }
  }

  # Enable cluster creator admin permissions
  enable_cluster_creator_admin_permissions = true

  tags = {
    Environment = "dev"
    Project     = "DEPI-206"
    Terraform   = "true"
  }
}

# Define the security group for the EKS cluster
resource "aws_security_group" "eks_cluster_sg" {
  vpc_id = aws_vpc.main.id
  name   = "eks-cluster-SG"

  # Allow incoming traffic from the Bastion host security group
  ingress {
    from_port   = 443  # Kubernetes API server port
    to_port     = 443
    protocol    = "tcp"
    security_groups = [aws_security_group.bastion-host-sg.id]  # Reference to bastion host SG
  }

  # Allow all egress traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-cluster-SG"
  }

  
}

# Fetch the existing EKS cluster security group
data "aws_security_group" "eks_cluster_sg" {
  filter {
    name   = "group-name"
    values = ["eks-cluster-sg-DevOps-DEPI-206-eks-cluster-*"]
  }
}

# Update the EKS cluster security group to allow traffic from the bastion host
resource "aws_security_group_rule" "allow_bastion_to_eks" {
  type                      = "ingress"
  from_port                 = 443
  to_port                   = 443
  protocol                  = "tcp"
  security_group_id         = data.aws_security_group.eks_cluster_sg.id
  source_security_group_id   = aws_security_group.bastion-host-sg.id
}
# Update the EKS cluster security group to allow traffic from the Jenkins host
resource "aws_security_group_rule" "allow_Jenkins_to_eks" {
  type                      = "ingress"
  from_port                 = 443
  to_port                   = 443
  protocol                  = "tcp"
  security_group_id         = data.aws_security_group.eks_cluster_sg.id
  source_security_group_id   = aws_security_group.jenkins_sg.id
}