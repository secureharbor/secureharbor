variable "region" {
  default = "us-east-1"
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))

  default = [
    {
      rolearn  = "arn:aws:iam::66666666666:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AdministratorAccess_b28a75516054db94"
      username = "AWSReservedSSO_AdministratorAccess_b28a75516054db94"
      groups   = ["system:masters"]
    },
  ]
}

# If later we need to add extra accounts and users to access cluster

variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap."
  type        = list(string)

  default = [
    "66666666666",
  ]
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  default = [
    {
      userarn  = "arn:aws:iam::66666666666:user/sako"
      username = "sako"
      groups   = ["system:masters"]
    },
    # {
    #   userarn  = "arn:aws:iam::66666666666:user/user2"
    #   username = "user2"
    #   groups   = ["system:masters"]
    # },
  ]
}