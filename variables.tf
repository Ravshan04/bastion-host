variable "aws_region" {
  description = "AWS region for the lab"
  type        = string
  default     = "eu-west-1"
}

variable "admin_cidr" {
  description = "Trusted public IPv4 CIDR allowed to SSH to the bastion"
  type        = string

  validation {
    condition     = can(cidrhost(var.admin_cidr, 0)) && endswith(var.admin_cidr, "/32")
    error_message = "admin_cidr must be one trusted IPv4 /32 CIDR."
  }
}

variable "public_key" {
  description = "OpenSSH public key installed on both instances"
  type        = string
  sensitive   = true
}

variable "instance_type" {
  description = "EC2 instance size"
  type        = string
  default     = "t3.micro"
}

