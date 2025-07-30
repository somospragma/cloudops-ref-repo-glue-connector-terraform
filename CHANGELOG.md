# Changelog

Todos los cambios notables de este módulo serán documentados en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
y este proyecto adhiere a [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
- **BREAKING CHANGE**: Cambiado `glue_connections_config` de `list(object)` a `map(object)`
- Eliminado el campo `alias` de la configuración (ahora la key del map es el alias)
- Simplificada la lógica interna del módulo
- Mejorado el rendimiento al eliminar transformaciones innecesarias
- Cambiado `var.domain` por `var.client` según estándar de nomenclatura
- Eliminada variable `resource_tags` en favor del sistema de `additional_tags`

### Added
- Archivo `data.tf` para futuros recursos de datos
- Archivo `providers.tf` con configuración estándar
- Este archivo `CHANGELOG.md` para documentar cambios
- Directorio `sample/` con ejemplos completos de uso
- Función `generate_name` para nomenclatura consistente
- Función `generate_tags` para sistema de etiquetado centralizado
- Campo `additional_tags` para etiquetas específicas por recurso
- **README.md completo** con documentación detallada, ejemplos y guías

### Improved
- Sistema de etiquetado más flexible y consistente
- Documentación completa con ejemplos de todos los tipos de conexión
- Guías de migración y troubleshooting
- Estructura del módulo ahora cumple completamente con las reglas establecidas

### Migration Guide
Para migrar de la versión anterior:

**Antes:**
```hcl
glue_connections_config = [
  {
    alias = "my-connection"
    connection_type = "JDBC"
    # ...
  }
]
```

**Ahora:**
```hcl
glue_connections_config = {
  "my-connection" = {
    connection_type = "JDBC"
    # ...
  }
}
```

## [1.0.0] - 2025-07-30

### Added
- Módulo inicial para gestión de conexiones AWS Glue
- Soporte para todos los tipos de conexión: JDBC, KAFKA, MONGODB, NETWORK, MARKETPLACE, CUSTOM
- Integración con AWS Secrets Manager para credenciales
- Configuración flexible de red (VPC, subnets, security groups)
- Outputs completos para integración con otros recursos
- Validaciones automáticas según tipo de conexión
- Filtrado automático de propiedades permitidas por AWS
