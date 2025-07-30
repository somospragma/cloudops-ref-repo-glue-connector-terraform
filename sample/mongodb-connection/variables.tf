variable "client" {
  description = "Client name"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "glue_connections_config" {
  description = "Configuration for Glue connections"
  type        = any
}
