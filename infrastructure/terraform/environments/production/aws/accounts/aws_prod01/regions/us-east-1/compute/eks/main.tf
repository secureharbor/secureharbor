locals {
  name            = "master-${random_string.suffix.result}"
  cluster_version = "1.21"
  region          = "us-east-1"
}

################################################################################
# EKS Module
################################################################################

module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name    = local.name
  cluster_version = local.cluster_version

  vpc_id          = module.vpc.vpc_id
  subnets         = [module.vpc.private_subnets[0], module.vpc.public_subnets[1]]
  fargate_subnets = [module.vpc.private_subnets[2]]

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true



  worker_additional_security_group_ids = [aws_security_group.all_worker_mgmt.id]

  # Worker groups (using Launch Configurations)
  worker_groups = [
    {
      name                          = "worker-group-1"
      instance_type                 = "t3.medium"
      additional_userdata           = "Blue"
      asg_desired_capacity          = 2
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
    },
    {
      name                          = "worker-group-2"
      instance_type                 = "t3.medium"
      additional_userdata           = "Green"
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_two.id]
      asg_desired_capacity          = 3
    },
  ]

  # Worker groups (using Launch Templates)
  # worker_groups_launch_template = [
  #   {
  #     name                    = "spot-1"
  #     override_instance_types = ["m5.large", "m5a.large", "m5d.large", "m5ad.large"]
  #     spot_instance_pools     = 4
  #     asg_max_size            = 5
  #     asg_desired_capacity    = 5
  #     kubelet_extra_args      = "--node-labels=node.kubernetes.io/lifecycle=spot"
  #     public_ip               = true
  #   },
  # ]

  # # Managed Node Groups
  # node_groups_defaults = {
  #   ami_type  = "AL2_x86_64"
  #   disk_size = 50
  # }

  # node_groups = {
  #   example = {
  #     desired_capacity = 1
  #     max_capacity     = 10
  #     min_capacity     = 1

  #     instance_types = ["t3.large"]
  #     capacity_type  = "SPOT"
  #     k8s_labels = {
  #       Environment = "Master"
  #       GithubRepo  = "terraform-aws-eks"
  #       GithubOrg   = "terraform-aws-modules"
  #     }
  #     additional_tags = {
  #       ExtraTag = "Master"
  #     }
  #     taints = [
  #       {
  #         key    = "dedicated"
  #         value  = "gpuGroup"
  #         effect = "NO_SCHEDULE"
  #       }
  #     ]
  #     update_config = {
  #       max_unavailable_percentage = 50 # or set `max_unavailable`
  #     }
  #   }
  # }

  # # Fargate
  # fargate_profiles = {
  #   default = {
  #     name = "default"
  #     selectors = [
  #       {
  #         namespace = "kube-system"
  #         labels = {
  #           k8s-app = "kube-dns"
  #         }
  #       },
  #       {
  #         namespace = "default"
  #       }
  #     ]

  #     tags = {
  #       Owner = "Master"
  #     }

  #     timeouts = {
  #       create = "20m"
  #       delete = "20m"
  #     }
  #   }
  # }

  # AWS Auth (kubernetes_config_map)
  map_roles    = var.map_roles
  map_users    = var.map_users
  map_accounts = var.map_accounts

  tags = {
    Cluster_name = local.name
    GithubRepo   = "terraform-aws-eks"
    GithubOrg    = "terraform-aws-modules"
  }
}

################################################################################
# Disabled creation
################################################################################

# module "disabled_eks" {
#   source = "../.."

#   create_eks = false
# }

# module "disabled_fargate" {
#   source = "../../modules/fargate"

#   create_fargate_pod_execution_role = false
# }

# module "disabled_node_groups" {
#   source = "../../modules/node_groups"

#   create_eks = false
# }

################################################################################
# Kubernetes provider configuration
################################################################################

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

################################################################################
# Additional security groups for workers
################################################################################

resource "aws_security_group" "worker_group_mgmt_one" {
  name_prefix = "worker_group_mgmt_one"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
    ]
  }
}

resource "aws_security_group" "worker_group_mgmt_two" {
  name_prefix = "worker_group_mgmt_two"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "192.168.0.0/16",
    ]
  }
}

resource "aws_security_group" "all_worker_mgmt" {
  name_prefix = "all_worker_management"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
  }
}

################################################################################
# Supporting resources
################################################################################

data "aws_availability_zones" "available" {
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name                 = local.name
  cidr                 = "10.2.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["10.2.1.0/24", "10.2.2.0/24", "10.2.3.0/24"]
  public_subnets       = ["10.2.4.0/24", "10.2.5.0/24", "10.2.6.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/elb"              = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/internal-elb"     = "1"
  }

  tags = {
    Cluster_name = local.name
    GithubRepo   = "terraform-aws-eks"
    GithubOrg    = "terraform-aws-modules"
  }
}