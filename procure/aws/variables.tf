# Project

variable "region" {
  description = "The region where AWS resources will be created"
  type        = string
}

# Nodes

variable "node_count" {
  description = "Number of nodes to create"
  type        = number
}

variable "instance_name" {
  description = "Name of the EC2 instances"
  type        = string
}

variable "machine_type" {
  description = "The machine type of the EC2 instance"
  type        = string
}

variable "image" {
  description = "The image to use for the EC2 instance"
  type        = string
}

variable "ip_allow_http" {
  description = "IP addresses and/or ranges to allow HTTP traffic from"
  type	      = list(string)
}

variable "ip_allow_http_from_port" {
  description = "Ports that accept HTTP traffic. Start of range."
  type	      = number
}

variable "ip_allow_http_to_port" {
  description = "Ports that accept HTTP traffic. End of range."
  type	      = number
}

variable "ip_allow_ssh" {
  description = "IP addresses and/or ranges to allow SSH access from"
  type        = list(string)
}

variable "is_production" {
  description = "Whether or not this is a production deployment"
  type        = bool
  default     = false
}

# Startup

variable "repo_url" {
  description = "The github url of the node repo to clone"
  type	      = string
}

variable "repo_branch" {
  description = "The branch of the repo to checkout"
  type 	      = string
}

variable "docker_username" {
  description = "The username for the docker registry"
  type        = string
}

variable "docker_password" {
  description = "The password for the docker registry"
  type        = string
  sensitive   = true
}
