# Project

variable "project" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The region where GCP resources will be created"
  type        = string
}

variable "zone" {
  description = "The zone where GCP resources will be created"
  type        = string
}

# Nodes

variable "node_count" {
  description = "Number of nodes to create"
  type        = number
}

variable "instance_name" {
  description = "Name of the GCE instances"
  type        = string
}

variable "machine_type" {
  description = "The machine type of the GCE instance"
  type        = string
}

variable "image" {
  description = "The image to use for the GCE instance"
  type        = string
}

variable "ip_allow_http" {
  description = "IP addresses and/or ranges to allow HTTP traffic from"
  type	      = list(string)
}

variable"ip_allow_http_ports" {
  description = "Ports that accept HTTP traffic"
  type	      = list(string)
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
  description = "The github url of this repo"
  type	      = string
}

variable "repo_branch" {
  description = "The branch of this repo to use for deployment"
  type 	      = string
}

variable "docker_username" {
  description = "Dockerhub username, required for pulling private docker images (including the Infernet node)"
  type        = string
}

variable "docker_password" {
  description = "Dockerhub PAT, required for pulling private docker images (including the Infernet node)"
  type        = string
  sensitive   = true
}
