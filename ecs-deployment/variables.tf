variable "region" {
  type = string
  default = "us-east-2"
}
variable "app_name" {
  type = string
  default = "node-app" 
}

variable "project_name" {
    type = string
    default = "Challenge-node-app"
}
variable "VPC_cidr" {
  type = string
  default = "10.10.0.0/16" 
}
variable "subnet_priv1_cidr" {
  type = string
  default = "10.10.0.0/20"
}
variable "subnet_priv2_cidr" {
  type = string
  default = "10.10.16.0/20"
}
variable "subnet_pub1_cidr" {
  type = string
  default = "10.10.32.0/20"
} 
variable "subnet_pub2_cidr" {
  type = string
  default = "10.10.80.0/20"
}  
variable "AZ1" {
  type = string
  default = "us-east-2a"
}
variable "AZ2" {
  type = string
  default = "us-east-2b"
}
variable "cpu" {
    type = number
    default = 1024
}
variable "memory" {
    type = number
    default = 2048  
}
variable "image_tag" {
    type = string
    default = "latest"
}

variable "cluster_name" {
    type = string
    default = "Challenge"
}

variable "app_port" {
    description = "port of the app"
    type = number
    default = 80 
}
