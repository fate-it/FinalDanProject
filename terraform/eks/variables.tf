variable "region" {
  description = "AWS region; authenticate using AWS_PROFILE or the standard AWS credential chain."
  type        = string
  default     = "eu-central-1"
}

variable "cluster_name" {
  description = "Unique cluster name, also used as a DNS label."
  type        = string
  default     = "student1"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,38}[a-z0-9]$", var.cluster_name))
    error_message = "Use 2–40 lowercase letters, digits or hyphens; start with a letter and end with a letter/digit."
  }
}

variable "group_number" {
  description = "DAN.IT group number, included in DNS names as devops<number>."
  type        = number
  default     = 13

  validation {
    condition     = var.group_number > 0 && floor(var.group_number) == var.group_number
    error_message = "The group number must be a positive integer."
  }
}

variable "zone_name" {
  description = "Existing public Route 53 zone for your own domain or a delegated subdomain."
  type        = string

  validation {
    condition = length(var.zone_name) <= 253 && can(regex(
      "^([a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?\\.)+[a-z]([a-z0-9-]{0,61}[a-z0-9])?$",
      var.zone_name
    ))
    error_message = "Enter your domain or delegated subdomain in lowercase, without https://, a path or a trailing dot."
  }
}

variable "kubernetes_version" {
  description = "EKS Kubernetes version, verified against the AWS support calendar."
  type        = string
  default     = "1.35"
}

variable "api_allowed_cidrs" {
  description = "Public IPv4 CIDRs allowed to use the EKS API, typically your external IP with /32."
  type        = list(string)

  validation {
    condition = length(var.api_allowed_cidrs) > 0 && alltrue([
      for cidr in var.api_allowed_cidrs : can(cidrnetmask(cidr)) && cidr != "0.0.0.0/0"
    ])
    error_message = "Provide at least one valid IPv4 CIDR; do not expose the API to 0.0.0.0/0."
  }
}

variable "vpc_cidr" {
  description = "Address range for the dedicated project VPC."
  type        = string
  default     = "10.42.0.0/16"
}

variable "node_instance_type" {
  description = "One x86_64 node; t3.medium is sized for this small non-HA lab."
  type        = string
  default     = "t3.medium"
}
