# Basic JDBC Connection Example

This example demonstrates how to create a basic JDBC connection to a PostgreSQL database using direct credentials.

## Usage

1. Copy the example variables:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` with your actual values:
   - Update database connection details
   - Provide your subnet and security group IDs
   - Set your client, project, and environment names

3. Initialize and apply:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Security Note

This example uses direct credentials for simplicity. For production environments, consider using the `secrets-manager` example instead for better security.

## Resources Created

- 1 AWS Glue Connection (JDBC type)
- Connection configured with PostgreSQL driver
- Network configuration for VPC access
