variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "candidate_number" {
  type    = string
  default = "14"
}

variable "ecr_repository_url" {
  type    = string
  default = "244530008913.dkr.ecr.eu-west-1.amazonaws.com/wishifai-14"
}

variable "image_tag" {
  type = string
}

variable "bedrock_latency_threshold_ms" {
  type    = number
  default = 30000
}