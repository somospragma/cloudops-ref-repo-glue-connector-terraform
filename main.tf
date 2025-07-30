
resource "aws_glue_connection" "connections" {
  provider = aws.project
  for_each = local.connections_config

  name            = "${var.client}-${var.project}-${var.environment}-glue-connection-${each.key}"
  description     = each.value.description
  connection_type = each.value.connection_type

  # Propiedades de conexión construidas dinámicamente
  connection_properties = length(local.connection_properties[each.key]) > 0 ? local.connection_properties[each.key] : null

  # Configuración de red (cuando aplique)
  dynamic "physical_connection_requirements" {
    for_each = (
      each.value.physical_connection_requirements != null ? [each.value.physical_connection_requirements] :
      (contains(["JDBC", "CUSTOM", "NETWORK"], each.value.connection_type) &&
        (each.value.subnet_id != null || length(each.value.security_group_id_list) > 0)) ? [{
          availability_zone      = each.value.availability_zone
          security_group_id_list = each.value.security_group_id_list
          subnet_id              = each.value.subnet_id
      }] : []
    )
    
    content {
      availability_zone      = physical_connection_requirements.value.availability_zone
      security_group_id_list = physical_connection_requirements.value.security_group_id_list
      subnet_id             = physical_connection_requirements.value.subnet_id
    }
  }

  # Etiquetas
  tags = merge(
    {
      Name = "${var.client}-${var.project}-${var.environment}-glue-connection-${each.key}"
      Type = each.value.connection_type
    },
    each.value.additional_tags
  )
}