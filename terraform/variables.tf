variable "aws_region" {
  default = "ap-south-1"
}

variable "availability_zone" {
  default = "ap-south-1a"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "key_name" {
  description = "AWS Key Pair"
  type        = string
  default     = "sadiq"
}


variable "vpc_cidr" {
  description = "VPC CIDR Block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "Public Subnet CIDR"
  type        = string
  default     = "10.0.1.0/24"
}

