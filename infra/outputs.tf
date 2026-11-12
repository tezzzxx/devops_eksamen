output "service_url" {
  description = "Offentlig URL til tjenesten"
  value       = try(aws_ecs_express_gateway_service.app.ingress_paths[0].endpoint, null)
}

output "s3_bucket" {
  value = aws_s3_bucket.images.bucket
}

output "service_arn" {
  value = aws_ecs_express_gateway_service.app.service_arn
}

output "dashboard_name" {
  value = aws_cloudwatch_dashboard.main.dashboard_name
}