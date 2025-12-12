variable "cidr_block" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
  validation {
    condition = alltrue([
      for s in concat(var.public_subnets, var.private_subnets) : tonumber(split("/", s)[1]) >= tonumber(split("/", var.cidr_block)[1])
    ])
    error_message = "Each subnet must have a prefix length that is equal or more specific than the VPC CIDR prefix (subnets must fit inside the VPC)."
  }
}

variable "region" {
  description = "AWS Region."
  type        = string
  default     = "eu-central-1"
}

variable "availability_zones" {
  description = "List of Availability Zones."
  type        = list(string)
  default     = ["eu-central-1a", "eu-central-1b"]
}

variable "public_subnets" {
  description = "CIDR blocks for public subnets."
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
  validation {
    condition     = length(var.public_subnets) == length(var.availability_zones)
    error_message = "public_subnets list length must equal availability_zones length"
  }
}

variable "private_subnets" {
  description = "CIDR blocks for private subnets."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
  validation {
    condition     = length(var.private_subnets) == length(var.availability_zones)
    error_message = "private_subnets list length must equal availability_zones length"
  }
}

variable "enable_nat_gateway" {
  description = "Whether to create NAT Gateways to allow private subnets outbound internet access."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "enable_vpn_gateway" {
  type    = bool
  default = false
}