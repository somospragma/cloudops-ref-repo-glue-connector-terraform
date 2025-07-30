
# data "aws_kms_alias" "sm" {
#   provider = aws.principal
#   name     = "alias/pragma-data-analytics-pdn-kms-sm"
# }

# data "aws_secretsmanager_secret" "sm-creci" {
#   provider = aws.principal
#   name     = "pragma/data-analytics/pdn/secret/creci"
# }

# data "aws_secretsmanager_secret" "sm-mission_match" {
#   provider = aws.principal
#   name     = "pragma/data-analytics/pdn/secret/mission_match"
# }

# data "aws_subnet" "data" {
#   provider = aws.principal
#   filter {
#     name   = "tag:Name"
#     values = ["pragma-network-prod-subnet-data-1"]
#   }
# }

# data "aws_security_group" "data" {
#   provider = aws.principal
#   filter {
#     name   = "group-name"
#     values = ["pragma-data-analytics-pdn-sg-glue-analytics"]
#   }
# }
