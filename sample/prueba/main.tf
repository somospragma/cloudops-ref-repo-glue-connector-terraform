# ##############################################################
# # Modulo SM
# ##############################################################
# module "sm-data-analytics" {
#   source = "git@ssh.dev.azure.com:v3/IaCPragma7000/Pragma7000-Modulos-Referencia/pragma-7000-terraform-parameterstore-tf?ref=module-parameterstore-analytics"
#   providers = {
#     aws.project = aws.principal
#   }
#   client          = var.client
#   project         = var.project
#   environment     = var.environment
#   parameter_store_config = {
#     # Parámetro de configuración simple
#     "SlackWebhook" = {
#       type        = "String"
#       value       = "https://hooks.slack.com/services/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"
#       description = "SlackWebhook"
#       custom_name = "/SDLF/Lambda/SlackWebhook"
#       tier        = "Standard"
#     }
    
#     # Parámetro sensible con cifrado
#     "QuicksightSlackDependencies" = {
#       type        = "String"
#       value       = "arn:aws:lambda:us-east-1:676206933306:layer:quicksight-slack-dependencies:1"
#       description = "Rol Quicksight Slack"
#       custom_name = "/SDLF/Lambda/QuicksightSlackDependencies"
#       tier        = "Standard"
#     }
#   }
#   default_kms_key_id = data.aws_kms_alias.sm.arn
# }

##############################################################
# Modulo Glue Connector
##############################################################
module "glue_connections" {
  #source = "git::https://github.com/somospragma/cloudops-ref-repo-glue-connector-terraform.git?ref=main" 
  source = "../../" 
  providers = {
    aws.project = aws.principal
  }
  
  client      = var.client
  project     = var.project
  environment = var.environment
  
  glue_connections_config = {
  "creci_db_connection" = {
    connection_type = "JDBC"
    description     = "MySq database connection Creci"
    jdbc_url        = "jdbc:mysql://mapa-de-crecimiento-proddb.cvwxqwk0qsc2.us-east-1.rds.amazonaws.com:3306/chapter_administracion_prod"
    class_name      = "org.mysql.Driver"
    
    # secrets_manager_secret_arn = data.aws_secretsmanager_secret.sm-creci.arn
    
    # # Network configuration
    # subnet_id              = data.aws_subnet.data.id
    # security_group_id_list = [data.aws_security_group.data.id]
   
    # Additional tags
    additional_tags = {
      Application = "DataAnalytics"
    }
  },
  "mission_match_db_connection" = {
    connection_type = "JDBC"
    description     = "MySq database connection Creci"
    jdbc_url        = "jdbc:mysql://mission-match-prod-db.c7yetlpaneie.us-east-1.rds.amazonaws.com:3306/missionmatch_prod_db"
    class_name      = "org.mysql.Driver"
    
    # secrets_manager_secret_arn = data.aws_secretsmanager_secret.sm-mission_match.arn
    
    # # Network configuration
    # subnet_id              = data.aws_subnet.data.id
    # security_group_id_list = [data.aws_security_group.data.id]
   
    # Additional tags
    additional_tags = {
      Application = "DataAnalytics"
    }
  }

}
}
