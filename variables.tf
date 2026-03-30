variable "ec2_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "ec2_instance_name" {
  description = "EC2 instance name tag"
  type        = string
  default     = "nginx-server"
}

variable "s3_bucket_name" {
  description = "S3 bucket name"
  type        = string
  default     = "my-bucket-tp-iac"
}

variable "security_group_default_port" {
  description = "Default ingress port for the security group"
  type        = number
  default     = 80
}
