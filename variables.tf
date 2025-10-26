variable "region" {
  default = "ap-northeast-1"
}

variable "bucket_name" {
  description = "S3バケット名（ユニーク）"
  type        = string
}