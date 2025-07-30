# Módulo Terraform: cloudops-ref-repo-glue-connector-terraform

## Descripción

Este módulo de referencia permite crear y gestionar conexiones AWS Glue de manera estandarizada y segura. Soporta todos los tipos de conexión disponibles (JDBC, KAFKA, MONGODB, NETWORK, MARKETPLACE, CUSTOM) con integración nativa a AWS Secrets Manager para el manejo seguro de credenciales.

El módulo implementa las mejores prácticas de seguridad, nomenclatura consistente y configuración flexible para adaptarse a diferentes casos de uso empresariales.

## Requisitos

- Terraform >= 1.10.1
- AWS Provider >= 5.0.0
- Permisos IAM para gestionar recursos AWS Glue
- (Opcional) AWS Secrets Manager para credenciales seguras

## Recursos Creados

- **aws_glue_connection**: Conexiones Glue configuradas según los parámetros especificados
- Soporte para configuración de red (VPC, subnets, security groups)
- Integración automática con AWS Secrets Manager
- Sistema de etiquetado consistente

## Configuración de Providers

Este módulo requiere que se le pase un provider AWS con el alias `project`. Ejemplo:

```hcl
provider "aws" {
  region = "us-east-1"
  alias  = "principal"
  
  default_tags {
    tags = {
      Client      = var.client
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

module "glue_connections" {
  source = "path/to/this/module"
  
  providers = {
    aws.project = aws.principal
  }
  
  # resto de la configuración...
}
```

## Uso Básico

```hcl
module "glue_connections" {
  source = "path/to/this/module"
  
  providers = {
    aws.project = aws.principal
  }
  
  client      = "mi-cliente"
  project     = "mi-proyecto"
  environment = "dev"
  
  glue_connections_config = {
    "postgres-db" = {
      connection_type = "JDBC"
      description     = "Conexión a base de datos PostgreSQL"
      jdbc_url        = "jdbc:postgresql://db.example.com:5432/mydb"
      class_name      = "org.postgresql.Driver"
      
      # Usar Secrets Manager (RECOMENDADO)
      secrets_manager_secret_arn = "arn:aws:secretsmanager:us-east-1:123456789012:secret:db-credentials-abc123"
      
      # Configuración de red
      subnet_id              = "subnet-12345678"
      security_group_id_list = ["sg-12345678"]
      availability_zone      = "us-east-1a"
      
      additional_tags = {
        Application = "DataPipeline"
        Team        = "Analytics"
      }
    }
  }
}
```

## Variables de Entrada

| Nombre | Descripción | Tipo | Valor por defecto | Requerido |
|--------|-------------|------|------------------|:---------:|
| client | Cliente al que pertenece el recurso | `string` | n/a | sí |
| project | Nombre del proyecto | `string` | n/a | sí |
| environment | Entorno (dev, qa, pdn) | `string` | n/a | sí |
| glue_connections_config | Configuración de conexiones Glue | `map(object)` | `{}` | sí |

### Estructura de glue_connections_config

```hcl
glue_connections_config = {
  "connection-name" = {
    # OBLIGATORIO
    connection_type = string  # JDBC, KAFKA, MONGODB, NETWORK, MARKETPLACE, CUSTOM
    
    # OPCIONALES - Configuración general
    description = string
    
    # OPCIONALES - Configuración JDBC
    jdbc_url         = string
    class_name       = string
    require_ssl      = bool
    skip_certificate_validation = bool
    custom_jdbc_certificate = string
    custom_jdbc_certificate_string = string
    
    # OPCIONALES - Credenciales (elegir una opción)
    secrets_manager_secret_arn = string  # RECOMENDADO
    username = string  # Menos seguro
    password = string  # Menos seguro
    
    # OPCIONALES - Configuración de red
    subnet_id              = string
    security_group_id_list = list(string)
    availability_zone      = string
    
    # OPCIONALES - Configuración Kafka
    kafka_bootstrap_servers           = string
    kafka_ssl_enabled                = bool
    kafka_custom_cert                = string
    kafka_skip_custom_cert_validation = bool
    
    # OPCIONALES - Configuración MongoDB
    mongodb_host     = string
    mongodb_port     = string
    mongodb_database = string
    
    # OPCIONALES - Propiedades adicionales
    connection_properties = map(string)
    
    # OPCIONALES - Configuración de red avanzada
    physical_connection_requirements = object({
      availability_zone      = string
      security_group_id_list = list(string)
      subnet_id             = string
    })
    
    # OPCIONALES - Etiquetas adicionales
    additional_tags = map(string)
  }
}
```

## Outputs

| Nombre | Descripción |
|--------|-------------|
| glue_connections | Map completo con detalles de todas las conexiones creadas |
| glue_connection_names | Map de nombres de conexiones por alias |
| glue_connection_arns | Map de ARNs de conexiones por alias |
| glue_connections_by_type | Conexiones agrupadas por tipo |
| connection_names_for_jobs | Lista de nombres para usar en Glue jobs |
| connections_with_secrets_manager | Conexiones que usan Secrets Manager |
| connections_with_direct_credentials | Conexiones con credenciales directas (auditoría) |
| connections_security_summary | Resumen de métodos de autenticación |

## Seguridad

Este módulo implementa las mejores prácticas de seguridad para conexiones AWS Glue:

### 🔐 Gestión de Credenciales

- **Secrets Manager (RECOMENDADO)**: Integración nativa con AWS Secrets Manager para almacenamiento seguro de credenciales
- **Credenciales directas**: Soportadas pero no recomendadas para producción
- **Auditoría**: Outputs específicos para identificar conexiones con credenciales directas

### 🛡️ Configuración de Red

- Soporte completo para VPC, subnets y security groups
- Configuración automática según el tipo de conexión
- Validaciones para tipos que requieren configuración de red

### 🏷️ Etiquetado y Nomenclatura

- Nomenclatura consistente: `{client}-{project}-{environment}-glue-connection-{name}`
- Etiquetas estándar automáticas: Name, Type
- Soporte para etiquetas adicionales por recurso

### ✅ Validaciones

- Validación de tipos de conexión permitidos
- Validaciones condicionales según el tipo (ej: JDBC requiere jdbc_url)
- Filtrado automático de propiedades permitidas por AWS

## Tipos de Conexión Soportados

### JDBC
```hcl
"my-database" = {
  connection_type = "JDBC"
  jdbc_url        = "jdbc:postgresql://host:5432/db"
  class_name      = "org.postgresql.Driver"
  secrets_manager_secret_arn = "arn:aws:secretsmanager:..."
  # configuración de red...
}
```

### KAFKA
```hcl
"my-kafka" = {
  connection_type         = "KAFKA"
  kafka_bootstrap_servers = "kafka1:9092,kafka2:9092"
  kafka_ssl_enabled      = true
  secrets_manager_secret_arn = "arn:aws:secretsmanager:..."
}
```

### MONGODB
```hcl
"my-mongodb" = {
  connection_type  = "MONGODB"
  mongodb_host     = "mongodb.example.com"
  mongodb_port     = "27017"
  mongodb_database = "mydb"
  secrets_manager_secret_arn = "arn:aws:secretsmanager:..."
}
```

### NETWORK
```hcl
"my-network" = {
  connection_type = "NETWORK"
  subnet_id       = "subnet-12345678"
  security_group_id_list = ["sg-12345678"]
}
```

### MARKETPLACE y CUSTOM
```hcl
"my-custom" = {
  connection_type = "CUSTOM"
  connection_properties = {
    "CUSTOM_PROPERTY" = "value"
  }
}
```

## Ejemplos

El directorio `sample/` contiene múltiples ejemplos organizados por caso de uso:

### 📁 `basic-jdbc/`
Conexión JDBC básica con credenciales directas (ideal para desarrollo y pruebas)

### 📁 `secrets-manager/`
Conexiones seguras usando AWS Secrets Manager (RECOMENDADO para producción)

### 📁 `kafka-integration/`
Conexión a clúster Kafka con configuración SSL

### 📁 `mongodb-connection/`
Conexión a MongoDB con propiedades personalizadas

### Uso Rápido

```bash
# Elegir el ejemplo que necesites
cd sample/secrets-manager/  # Para producción (recomendado)
# cd sample/basic-jdbc/     # Para desarrollo

cp terraform.tfvars.example terraform.tfvars
# Editar terraform.tfvars con tus valores
terraform init
terraform plan
terraform apply
```

## Migración desde Versiones Anteriores

### De list(object) a map(object)

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

## Troubleshooting

### Error: "connection_type must be one of..."
- Verificar que el `connection_type` sea uno de los valores permitidos: JDBC, KAFKA, MONGODB, NETWORK, MARKETPLACE, CUSTOM

### Error: "JDBC connections require jdbc_url"
- Para conexiones JDBC, el campo `jdbc_url` es obligatorio

### Conexión no puede acceder a recursos en VPC
- Verificar que `subnet_id` y `security_group_id_list` estén configurados correctamente
- Verificar que el security group permita el tráfico necesario

### Credenciales no funcionan
- Si usas Secrets Manager, verificar que el ARN sea correcto y que Glue tenga permisos para acceder al secret
- Verificar que el formato del secret en Secrets Manager sea el esperado (username/password)

## Contribución

Para contribuir a este módulo:

1. Seguir las reglas establecidas en `Reglas_Modulos_Referencia_Actualizadas.md`
2. Actualizar `CHANGELOG.md` con los cambios
3. Agregar ejemplos en el directorio `sample/` si es necesario
4. Ejecutar validaciones de Terraform antes de enviar cambios

## Changelog

Ver [CHANGELOG.md](./CHANGELOG.md) para el historial completo de cambios.
