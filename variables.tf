variable "project" {
  type        = string
  description = "Project name"

  validation {
    condition     = length(var.project) > 0 && length(var.project) <= 50
    error_message = "Project name must be between 1 and 50 characters."
  }

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  type        = string
  description = "Environment name"

  validation {
    condition     = contains(["dev", "qa", "pdn"], var.environment)
    error_message = "Environment must be one of: dev, qa, pdn."
  }
}

variable "client" {
  type        = string
  description = "Client name"

  validation {
    condition     = length(var.client) > 0 && length(var.client) <= 50
    error_message = "Client name must be between 1 and 50 characters."
  }

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.client))
    error_message = "Client name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "glue_connections_config" {
  description = "Configuration for Glue connections"
  type = map(object({
    # Required
    connection_type = string

    # Optional - General
    description = optional(string)

    # Optional - JDBC
    jdbc_url                       = optional(string)
    class_name                     = optional(string)
    require_ssl                    = optional(bool)
    skip_certificate_validation    = optional(bool)
    custom_jdbc_certificate        = optional(string)
    custom_jdbc_certificate_string = optional(string)

    # Optional - Credentials (choose one approach)
    secrets_manager_secret_arn = optional(string) # RECOMMENDED
    username                   = optional(string) # Less secure
    password                   = optional(string) # Less secure

    # Optional - Network
    subnet_id              = optional(string)
    security_group_id_list = optional(list(string))
    availability_zone      = optional(string)

    # Optional - Kafka
    kafka_bootstrap_servers           = optional(string)
    kafka_ssl_enabled                 = optional(bool)
    kafka_custom_cert                 = optional(string)
    kafka_skip_custom_cert_validation = optional(bool)

    # Optional - MongoDB
    mongodb_host     = optional(string)
    mongodb_port     = optional(string)
    mongodb_database = optional(string)

    # Optional - Advanced
    connection_properties = optional(map(string))
    physical_connection_requirements = optional(object({
      availability_zone      = string
      security_group_id_list = list(string)
      subnet_id             = string
    }))

    # Optional - Tags
    additional_tags = optional(map(string))
  }))

  validation {
    condition = alltrue([
      for key, config in var.glue_connections_config :
      contains(["JDBC", "KAFKA", "MONGODB", "NETWORK", "MARKETPLACE", "CUSTOM"], config.connection_type)
    ])
    error_message = "connection_type must be one of: JDBC, KAFKA, MONGODB, NETWORK, MARKETPLACE, CUSTOM."
  }

  validation {
    condition = alltrue([
      for key, config in var.glue_connections_config :
      config.connection_type != "JDBC" || config.jdbc_url != null
    ])
    error_message = "JDBC connections require jdbc_url to be specified."
  }

  validation {
    condition = alltrue([
      for key, config in var.glue_connections_config :
      can(regex("^[a-zA-Z0-9_-]+$", key))
    ])
    error_message = "Connection names must contain only alphanumeric characters, underscores, and hyphens."
  }

  validation {
    condition = alltrue([
      for key, config in var.glue_connections_config :
      config.connection_type != "KAFKA" || config.kafka_bootstrap_servers != null
    ])
    error_message = "Kafka connections require kafka_bootstrap_servers to be specified."
  }

  validation {
    condition = alltrue([
      for key, config in var.glue_connections_config :
      config.connection_type != "MONGODB" || config.mongodb_host != null
    ])
    error_message = "MongoDB connections require mongodb_host to be specified."
  }
}
