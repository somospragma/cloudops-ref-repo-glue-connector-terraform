locals {
  # Normalize connection configurations with safe default values
  # This ensures all optional fields have consistent defaults to prevent validation errors
  connections_config = {
    for key, config in var.glue_connections_config : key => {
      # Campos obligatorios
      connection_type = config.connection_type
      
      # Campos con valores por defecto seguros usando coalesce
      description                    = coalesce(config.description, "Glue connection for ${key}")
      require_ssl                    = coalesce(config.require_ssl, false)
      skip_certificate_validation    = coalesce(config.skip_certificate_validation, false)
      custom_jdbc_certificate        = config.custom_jdbc_certificate
      custom_jdbc_certificate_string = config.custom_jdbc_certificate_string
      username                       = config.username
      password                       = config.password
      secrets_manager_secret_arn     = config.secrets_manager_secret_arn
      subnet_id                      = config.subnet_id
      security_group_id_list         = coalesce(config.security_group_id_list, [])
      availability_zone              = config.availability_zone
      connection_properties          = coalesce(config.connection_properties, {})
      kafka_bootstrap_servers        = config.kafka_bootstrap_servers
      kafka_ssl_enabled              = coalesce(config.kafka_ssl_enabled, false)
      kafka_custom_cert              = config.kafka_custom_cert
      kafka_skip_custom_cert_validation = coalesce(config.kafka_skip_custom_cert_validation, false)
      mongodb_host                   = config.mongodb_host
      mongodb_port                   = coalesce(config.mongodb_port, "27017")
      mongodb_database               = config.mongodb_database
      jdbc_url                       = config.jdbc_url
      class_name                     = config.class_name
      physical_connection_requirements = config.physical_connection_requirements
      additional_tags                = coalesce(config.additional_tags, {})
    }
  }

  # Build connection properties dynamically based on connection type
  # Simplified to avoid SSL-related properties that cause AWS Glue validation errors
  connection_properties = {
    for key, normalized_config in local.connections_config : key => merge(
      # Propiedades personalizadas del usuario
      normalized_config.connection_properties,
      
      # Propiedades JDBC
      normalized_config.connection_type == "JDBC" ? merge(
        {
          for k, v in {
            "JDBC_CONNECTION_URL"    = normalized_config.jdbc_url
            "JDBC_DRIVER_CLASS_NAME" = normalized_config.class_name
          } : k => v if v != null && v != ""
        },
        normalized_config.secrets_manager_secret_arn != null ? {
          "SECRET_ID" = normalized_config.secrets_manager_secret_arn
        } : {
          for k, v in {
            "USERNAME" = normalized_config.username
            "PASSWORD" = normalized_config.password
          } : k => v if v != null && v != ""
        }
      ) : {},
      
      # Propiedades Kafka
      normalized_config.connection_type == "KAFKA" ? merge(
        {
          for k, v in {
            "KAFKA_BOOTSTRAP_SERVERS"           = normalized_config.kafka_bootstrap_servers
            "KAFKA_SSL_ENABLED"                 = normalized_config.kafka_ssl_enabled ? "true" : "false"
            "KAFKA_CUSTOM_CERT"                 = normalized_config.kafka_custom_cert
            "KAFKA_SKIP_CUSTOM_CERT_VALIDATION" = normalized_config.kafka_skip_custom_cert_validation ? "true" : "false"
          } : k => v if v != null && v != ""
        },
        normalized_config.secrets_manager_secret_arn != null ? {
          "KAFKA_SASL_SCRAM_SECRETS_ARN" = normalized_config.secrets_manager_secret_arn
        } : {
          for k, v in {
            "USERNAME" = normalized_config.username
            "PASSWORD" = normalized_config.password
          } : k => v if v != null && v != ""
        }
      ) : {},
      
      # Propiedades MongoDB
      normalized_config.connection_type == "MONGODB" ? merge(
        normalized_config.mongodb_host != null ? {
          "CONNECTION_URL" = "mongodb://${normalized_config.mongodb_host}:${normalized_config.mongodb_port}/${normalized_config.mongodb_database != null ? normalized_config.mongodb_database : ""}"
        } : {},
        normalized_config.secrets_manager_secret_arn != null ? {
          "SECRET_ID" = normalized_config.secrets_manager_secret_arn
        } : {
          for k, v in {
            "USERNAME" = normalized_config.username
            "PASSWORD" = normalized_config.password
          } : k => v if v != null && v != ""
        }
      ) : {}
    )
  }
}
