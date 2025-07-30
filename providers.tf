# providers.tf - Configuración de providers para el módulo Glue Connections

terraform {
  required_version = ">= 1.10.1"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 5.0.0"
      configuration_aliases = [aws.project]
    }
  }
}

# Este módulo requiere que se le pase un provider AWS con el alias 'project'
# El consumidor del módulo debe configurar el provider de la siguiente manera:
#
# provider "aws" {
#   region = var.region
#   alias  = "principal"
#   
#   default_tags {
#     tags = {
#       environment = var.environment
#       project     = var.project
#       owner       = var.owner
#       client      = var.client
#       provisioned = "terraform"
#     }
#   }
# }
#
# module "glue_connections" {
#   source = "path/to/this/module"
#   
#   providers = {
#     aws.project = aws.principal
#   }
#   
#   # resto de la configuración...
# }
