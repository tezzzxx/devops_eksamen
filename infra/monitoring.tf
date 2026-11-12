locals {
  metrics_namespace = "wishifai-${var.candidate_number}"
  service_name      = aws_ecs_express_gateway_service.app.service_name
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "wishifai-${var.candidate_number}"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "text"
        x      = 0
        y      = 0
        width  = 24
        height = 1
        properties = {
          markdown = "## Wishifai ${var.candidate_number}: forretning, applikasjon og infrastruktur"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 1
        width  = 12
        height = 6
        properties = {
          title  = "Business: analyser og gaveforslag (per 5 min)"
          region = var.region
          view   = "timeSeries"
          stat   = "Sum"
          period = 300
          metrics = [
            [local.metrics_namespace, "wishifai.suggestions.count.count", { label = "Bilder analysert" }],
            [local.metrics_namespace, "wishifai.suggestions.count.sum", { label = "Gaveforslag generert" }]
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 1
        width  = 12
        height = 6
        properties = {
          title  = "Applikasjon: latens Rekognition vs Bedrock (ms)"
          region = var.region
          view   = "timeSeries"
          stat   = "Average"
          period = 60
          metrics = [
            [local.metrics_namespace, "wishifai.rekognition.latency.avg", { label = "Rekognition" }],
            [local.metrics_namespace, "wishifai.bedrock.latency.avg", { label = "Bedrock" }]
          ]
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 7
        width  = 8
        height = 6
        properties = {
          title  = "Infrastruktur: ECS CPU og minne (%)"
          region = var.region
          view   = "timeSeries"
          stat   = "Average"
          period = 60
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ClusterName", "default", "ServiceName", local.service_name, { label = "CPU" }],
            ["AWS/ECS", "MemoryUtilization", "ClusterName", "default", "ServiceName", local.service_name, { label = "Minne" }]
          ]
        }
      },
      {
        type   = "metric"
        x      = 8
        y      = 7
        width  = 8
        height = 6
        properties = {
          title  = "Applikasjon (Actuator): JVM heap brukt (bytes)"
          region = var.region
          view   = "timeSeries"
          period = 60
          metrics = [
            [{
              expression = "SUM(SEARCH('{${local.metrics_namespace},area,id} MetricName=\"jvm.memory.used.value\" area=\"heap\"', 'Average', 60))"
              label      = "Heap brukt"
              id         = "heap"
            }]
          ]
        }
      },
      {
        type   = "metric"
        x      = 16
        y      = 7
        width  = 8
        height = 6
        properties = {
          title  = "Applikasjon (Actuator): HTTP-responstid /api/analyze (ms)"
          region = var.region
          view   = "timeSeries"
          period = 60
          metrics = [
            [{
                            expression = "AVG(SEARCH('Namespace=\"${local.metrics_namespace}\" MetricName=\"http.server.requests.avg\" uri=\"/api/analyze\"', 'Average', 60))"
              label      = "Snitt responstid"
              id         = "http"
            }]
          ]
        }
      }
    ]
  })
}

resource "aws_cloudwatch_metric_alarm" "bedrock_latency" {
  alarm_name          = "wishifai-${var.candidate_number}-bedrock-latency"
  namespace           = local.metrics_namespace
  metric_name         = "wishifai.bedrock.latency.avg"
  statistic           = "Average"
  period              = 60
  evaluation_periods  = 3
  threshold           = var.bedrock_latency_threshold_ms
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"
}