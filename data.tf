# data.tf - Recursos de datos para el módulo Glue Connections

# Este archivo contiene los recursos de datos (data sources) utilizados por el módulo
# Por ahora está vacío, pero se puede usar para consultar información de AWS como:
# - VPCs existentes
# - Subnets
# - Security Groups
# - Secrets Manager secrets
# - etc.

# Ejemplo de uso futuro:
# data "aws_vpc" "selected" {
#   count = var.vpc_id != null ? 1 : 0
#   id    = var.vpc_id
# }
