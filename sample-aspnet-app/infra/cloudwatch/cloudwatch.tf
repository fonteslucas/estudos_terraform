variable "microservicename" {
    type = string
}

resource "aws_cloudwatch_log_group" "log_group" {
    name = "/ecs/${var.microservicename}"
    retention_in_days = 7
}

output "cloudwatch_name" {
    value = aws_cloudwatch_log_group.log_group.name
}