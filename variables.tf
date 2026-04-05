variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "admin_cidr" {
  description = "CIDR allowed to SSH to web instances."
  type        = string
}

variable "key_name" {
  description = "EC2 key pair name to use for web/app instances."
  type        = string
}

variable "web_instance_type" {
  description = "Instance type for web tier instances."
  type        = string
  default     = "t2.micro"
}

variable "app_instance_type" {
  description = "Instance type for app tier instances."
  type        = string
  default     = "t2.micro"
}

variable "app_port" {
  description = "Application port exposed by app tier."
  type        = number
  default     = 8080
}

variable "db_engine" {
  description = "RDS engine."
  type        = string
  default     = "mysql"
}

variable "db_instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Allocated storage in GB for RDS."
  type        = number
  default     = 20
}

variable "db_port" {
  description = "Database port."
  type        = number
  default     = 3306
}

variable "db_identifier" {
  description = "DB instance identifier."
  type        = string
  default     = "my-3tier-db"
}

variable "db_username" {
  description = "RDS master username."
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "RDS master password."
  type        = string
  sensitive   = true
}

variable "db_multi_az" {
  description = "Enable Multi-AZ for RDS."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags to apply to resources."
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "3tier-vpc"
  }
}
