module "glue_connections" {
  source = "../../"
  
  providers = {
    aws.project = aws.principal
  }
  
  client      = var.client
  project     = var.project
  environment = var.environment
  
  glue_connections_config = var.glue_connections_config
}
