terraform {
  backend "s3" {
    bucket = "nicholasmpaz-terraform"
    key    = "albatross/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.region
}

module "db" {
  source = "./db"
}

resource "aws_s3_bucket" "prod" {
  bucket = var.root_domain_name
  acl    = "public-read"
  policy = <<POLICY
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Sid":"AddPermissions",
      "Effect":"Allow",
      "Principal": "*",
      "Action":["s3:GetObject"],
      "Resource":["arn:aws:s3:::${var.root_domain_name}/*"]
    }
  ]
}
POLICY
  website {
    index_document = "index.html"
  }
}

resource "aws_s3_bucket" "dev" {
  bucket = var.dev_domain_name
  acl    = "public-read"
  policy = <<POLICY
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Sid":"AddPermissions",
      "Effect":"Allow",
      "Principal": "*",
      "Action":["s3:GetObject"],
      "Resource":["arn:aws:s3:::${var.dev_domain_name}/*"]
    }
  ]
}
POLICY
  website {
    index_document = "index.html"
  }
}

resource "aws_acm_certificate" "default" {
  domain_name               = "*.${var.root_domain_name}"
  subject_alternative_names = [var.root_domain_name]
  validation_method         = "DNS"
}

resource "aws_route53_record" "validation" {
  name    = aws_acm_certificate.default.domain_validation_options.0.resource_record_name
  type    = aws_acm_certificate.default.domain_validation_options.0.resource_record_type
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  records = ["${aws_acm_certificate.default.domain_validation_options.0.resource_record_value}"]
  ttl     = "60"
}

resource "aws_acm_certificate_validation" "default" {
  certificate_arn = aws_acm_certificate.default.arn
  validation_record_fqdns = [
    "${aws_route53_record.validation.fqdn}",
  ]
}

resource "aws_cloudfront_distribution" "www_distribution" {
  origin {
    domain_name = aws_s3_bucket.prod.bucket_regional_domain_name
    origin_id   = var.www_domain_name
  }
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  aliases             = [var.www_domain_name, var.root_domain_name]

  default_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = var.www_domain_name
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000

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
    acm_certificate_arn      = aws_acm_certificate_validation.default.certificate_arn
    minimum_protocol_version = "TLSv1"
    ssl_support_method       = "sni-only"
  }
}

resource "aws_cloudfront_distribution" "dev" {
  origin {
    domain_name = aws_s3_bucket.dev.bucket_regional_domain_name
    origin_id   = var.dev_domain_name
  }
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  aliases             = [var.dev_domain_name]

  default_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = var.dev_domain_name
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0

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
    acm_certificate_arn      = aws_acm_certificate_validation.default.certificate_arn
    minimum_protocol_version = "TLSv1"
    ssl_support_method       = "sni-only"
  }
}

resource "aws_route53_record" "dev" {
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  name    = var.dev_domain_name
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.dev.domain_name
    zone_id                = aws_cloudfront_distribution.dev.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  name    = var.www_domain_name
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.www_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.www_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}



resource "aws_route53_record" "root" {
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  name    = var.root_domain_name
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.www_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.www_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

output "bucket_prod" {
  value       = aws_s3_bucket.prod.id
  description = "test"
}

output "bucket_dev" {
  value       = aws_s3_bucket.dev.id
  description = "test"
}