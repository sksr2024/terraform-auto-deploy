# S3バケット名
output "s3_bucket_name" {
  description = "Name of the S3 bucket hosting the static site"
  value       = aws_s3_bucket.static_site.bucket
}

# S3バケットのウェブサイトエンドポイント(直接アクセス用)
output "s3_website_endpoint" {
  description = "Website endpoint of the S3 bucket"
  value       = aws_s3_bucket.static_site.bucket_regional_domain_name
}

# CloudFront ドメイン名(配信URL)
output "cloudfront_domain_name" {
  description = "The domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.cdn.domain_name
}

# CloudFrontディストリビューションID(デプロイや更新確認用)
output "aws_cloudfront_distribution_id" {
  description = "The ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.cdn.id
}