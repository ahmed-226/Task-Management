# ===========================================
# Variables - Customize your deployment
# ===========================================

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "task-management"
}

# ===========================================
# EC2 Configuration
# ===========================================

variable "instance_type" {
  description = "EC2 instance type (t2.micro is free tier eligible)"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Name of the SSH key pair for EC2 access"
  type        = string
  default     = ""
}

# ===========================================
# Network Configuration
# ===========================================

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed for SSH access (your IP)"
  type        = string
  default     = "0.0.0.0/0" # Change to your IP for security
}

# ===========================================
# Application Configuration
# ===========================================

variable "mongodb_version" {
  description = "MongoDB version to install"
  type        = string
  default     = "7.0"
}

variable "node_version" {
  description = "Node.js version to install"
  type        = string
  default     = "18"
}
