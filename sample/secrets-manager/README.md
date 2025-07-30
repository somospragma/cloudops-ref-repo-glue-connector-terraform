# Secure Connections with AWS Secrets Manager

This example demonstrates how to create secure Glue connections using AWS Secrets Manager for credential management.

## Prerequisites

Before using this example, you need to create secrets in AWS Secrets Manager:

### For JDBC connections:
```json
{
  "username": "your-db-username",
  "password": "your-db-password"
}
```

### For Kafka connections:
```json
{
  "username": "your-kafka-username",
  "password": "your-kafka-password"
}
```

## Usage

1. Create your secrets in AWS Secrets Manager first
2. Copy the example variables:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```
3. Edit `terraform.tfvars` with your actual values:
   - Update the Secrets Manager ARNs
   - Provide your connection details
   - Set your client, project, and environment names
4. Initialize and apply:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Security Benefits

- Credentials are stored securely in AWS Secrets Manager
- Automatic rotation capabilities
- Fine-grained access control through IAM
- Audit trail of credential access
- No credentials in Terraform state

## Resources Created

- Multiple AWS Glue Connections using Secrets Manager
- Secure credential management
- Network configuration for VPC access
