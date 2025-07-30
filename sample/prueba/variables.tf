##############################################################
# Variables Globales
##############################################################
variable "client" {
  description = "Nombre del cliente asociado a las zonas Route 53"
  type        = string
}

variable "project" {
  description = "Nombre del proyecto asociado a las zonas Route 53"
  type        = string
}

variable "environment" {
  description = "Entorno en el que se desplegarán las zonas Route 53 (develop, dev, qa, pdn)"
  type        = string
  validation {
    condition     = contains(["develop", "dev", "qa", "pdn"], var.environment)
    error_message = "El entorno debe ser uno de: develop, dev, qa, pdn"
  }
}

variable "aws_region" {
  description = "Región de AWS donde se desplegarán los recursos"
  type        = string
  default     = ""
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags to be applied to the resources"
}

# variable "deploy_role_arn" {
#   type        = string
#   description = "Rol Deployment IaC"
# }