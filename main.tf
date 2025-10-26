terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  # backend "s3" {} # 後ほどGitHub Actions対応時に設定
}

provider "aws" {
  region = var.region
}

# S3バケット（静的サイトホスティング用）
resource "aws_s3_bucket" "static_site" {
  bucket = var.bucket_name
}

# CloudFront用のOAI
resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for ${aws_s3_bucket.static_site.id}"
}

resource "aws_s3_bucket_website_configuration" "site_config" {
  bucket = aws_s3_bucket.static_site.id

  index_document {
    suffix = "index.html"
  }
}

# バケットポリシー（OAIに限定）
resource "aws_s3_bucket_policy" "public_policy" {
  bucket = aws_s3_bucket.static_site.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { CanonicalUser = aws_cloudfront_origin_access_identity.oai.s3_canonical_user_id }
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.static_site.arn}/*"
      }
    ]
  })
}

# CloudFrontディストリビューション
resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = aws_s3_bucket.static_site.bucket_regional_domain_name
    origin_id   = "S3-${aws_s3_bucket.static_site.id}"

    s3_origin_config {
      origin_access_identity = "origin-access-identity/cloudfront/${aws_cloudfront_origin_access_identity.oai.id}"
    }
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-${aws_s3_bucket.static_site.id}"
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
