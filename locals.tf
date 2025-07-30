locals {
  # Configuraciones con valores por defecto aplicados de forma robusta
  connections_config = {
    for key, config in var.glue_connections_config : key => {
      # Campos obligatorios
      connection_type = config.connection_type
      
      # Campos con valores por defecto seguros
      description                    = try(config.description, "Glue connection for ${key}")
      require_ssl                    = try(config.require_ssl, false)
      skip_certificate_validation    = try(config.skip_certificate_validation, false)
      custom_jdbc_certificate        = try(config.custom_jdbc_certificate, null)
      custom_jdbc_certificate_string = try(config.custom_jdbc_certificate_string, null)
      username                       = try(config.username, null)
      password                       = try(config.password, null)
      secrets_manager_secret_arn     = try(config.secrets_manager_secret_arn, null)
      subnet_id                      = try(config.subnet_id, null)
      security_group_id_list         = try(config.security_group_id_list, [])
      availability_zone              = try(config.availability_zone, null)
      connection_properties          = try(config.connection_properties, {})
      kafka_bootstrap_servers        = try(config.kafka_bootstrap_servers, null)
      kafka_ssl_enabled              = try(config.kafka_ssl_enabled, false)
      kafka_custom_cert              = try(config.kafka_custom_cert, null)
      kafka_skip_custom_cert_validation = try(config.kafka_skip_custom_cert_validation, false)
      mongodb_host                   = try(config.mongodb_host, null)
      mongodb_port                   = try(config.mongodb_port, "27017")
      mongodb_database               = try(config.mongodb_database, null)
      jdbc_url                       = try(config.jdbc_url, null)
      class_name                     = try(config.class_name, null)
      physical_connection_requirements = try(config.physical_connection_requirements, null)
      additional_tags                = try(config.additional_tags, {})
    }
  }

  # Construir propiedades de conexión por tipo
  connection_properties = {
    for key, config in local.connections_config : key => merge(
      # Propiedades personalizadas del usuario
      config.connection_properties,
      
      # Propiedades JDBC
      config.connection_type == "JDBC" ? merge(
        {
          for k, v in {
            "JDBC_CONNECTION_URL"              = config.jdbc_url
            "JDBC_DRIVER_CLASS_NAME"           = config.class_name
            "JDBC_ENFORCE_SSL"                 = config.require_ssl ? "true" : "false"
            "SKIP_CUSTOM_JDBC_CERT_VALIDATION" = config.skip_certificate_validation ? "true" : "false"
            "CUSTOM_JDBC_CERT"                 = config.custom_jdbc_certificate
            "CUSTOM_JDBC_CERT_STRING"          = config.custom_jdbc_certificate_string
          } : k => v if v != null && v != ""
        },
        config.secrets_manager_secret_arn != null ? {
          "SECRET_ID" = config.secrets_manager_secret_arn
        } : {
          for k, v in {
            "USERNAME" = config.username
            "PASSWORD" = config.password
          } : k => v if v != null && v != ""
        }
      ) : {},
      
      # Propiedades Kafka
      config.connection_type == "KAFKA" ? merge(
        {
          for k, v in {
            "KAFKA_BOOTSTRAP_SERVERS"           = config.kafka_bootstrap_servers
            "KAFKA_SSL_ENABLED"                 = config.kafka_ssl_enabled ? "true" : "false"
            "KAFKA_CUSTOM_CERT"                 = config.kafka_custom_cert
            "KAFKA_SKIP_CUSTOM_CERT_VALIDATION" = config.kafka_skip_custom_cert_validation ? "true" : "false"
          } : k => v if v != null && v != ""
        },
        config.secrets_manager_secret_arn != null ? {
          "KAFKA_SASL_SCRAM_SECRETS_ARN" = config.secrets_manager_secret_arn
        } : {
          for k, v in {
            "USERNAME" = config.username
            "PASSWORD" = config.password
          } : k => v if v != null && v != ""
        }
      ) : {},
      
      # Propiedades MongoDB
      config.connection_type == "MONGODB" ? merge(
        config.mongodb_host != null ? {
          "CONNECTION_URL" = "mongodb://${config.mongodb_host}:${config.mongodb_port}/${config.mongodb_database != null ? config.mongodb_database : ""}"
        } : {},
        config.secrets_manager_secret_arn != null ? {
          "SECRET_ID" = config.secrets_manager_secret_arn
        } : {
          for k, v in {
            "USERNAME" = config.username
            "PASSWORD" = config.password
          } : k => v if v != null && v != ""
        }
      ) : {}
    )
  }
}
