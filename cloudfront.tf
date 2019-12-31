resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  count = var.create_cloudfront ? 1 : 0

  comment = "${var.origin_id}-cloudfront-access-identity"
}

//locals {
//  domain_name = var.create_dns_record == true ? aws_route53_record.dns_record.*.name : var.dns_name
//}

variable "origin_domain_name" {
  description = "The DNS domain name of either the S3 bucket, or web site of your custom origin."
  default = ""
}

variable "origin_id" {
  description = "A unique identifier for the origin."
  default = "my_default_s3_origin"
}

variable "create_cloudfront" {
  // This may fuck you up later ben
  description = "True False on if to create cloudfront, defaults to true."
  default = true
}

variable "is_distribution_enabled" {
  description = "Whether the distribution is enabled to accept end user requests for content. Defaults to true"
  default = true
}

variable "is_ipv6_enabled" {
  description = "Whether the IPv6 is enabled for the distribution. Defaults to true"
  default = true
}

variable "default_root_object" {
  description = "The object that you want CloudFront to return (for example, index.html) when an end user requests the root URL. Defaults to Index.html"
  default = "index.html"
}

variable "aliases" {
  description = "Extra CNAMEs (alternate domain names), if any, for this distribution."
  default = []
}

variable "restrictions" {
  description = "The restrictions sub-resource takes another single sub-resource named geo_restriction."
  type = any
  default = {
    geo_restriction = {
      restriction_type = "none"
  }

  }
}

variable "default_cache_behavior_allowed_methods" {
  default = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
  description = "Controls which HTTP methods CloudFront processes and forwards to your Amazon S3 bucket or your custom origin."
}

variable "default_cache_behavior_cached_methods" {
  default = ["GET", "HEAD"]
  description = "Controls whether CloudFront caches the response to requests using the specified HTTP method"
}

variable "min_ttl" {
  description = "The minimum amount of time that you want objects to stay in CloudFront caches before CloudFront queries your origin to see whether the object has been updated. Defaults to 0 seconds."
  default = 0
}

variable "default_ttl" {
  description = "The default amount of time (in seconds) that an object is in a CloudFront cache before CloudFront forwards another request in the absence of an Cache-Control max-age or Expires header. Defaults to 1 day."
  default = 3600
}

variable "max_ttl" {
  description = "The maximum amount of time (in seconds) that an object is in a CloudFront cache before CloudFront forwards another request to your origin to determine whether the object has been updated. Only effective in the presence of Cache-Control max-age, Cache-Control s-maxage, and Expires headers. Defaults to 365 days."
  default = 86400
}

variable "price_class" {
  description = "The price class for this distribution. One of PriceClass_All, PriceClass_200, PriceClass_100"
  default = "PriceClass_100"
}

resource "aws_cloudfront_distribution" "main" {
  count = var.create_cloudfront ? 1 : 0

  origin {
    domain_name = element(aws_s3_bucket.the_bucket.*.bucket_regional_domain_name, 0)
    origin_id = var.origin_id

    s3_origin_config {
      origin_access_identity = element(aws_cloudfront_origin_access_identity.origin_access_identity.*.cloudfront_access_identity_path, 0)
    }
  }

  dynamic "restrictions" {
    for_each = length(keys(var.restrictions)) == 0 ? [] : [var.restrictions]

    content {
      dynamic "geo_restriction" {
        for_each = length(keys(lookup(restrictions.value, "geo_restriction", {}))) == 0 ? [] : [lookup(restrictions.value, "geo_restriction", {})]

        content {
          locations = lookup(geo_restriction.value, "locations", null)
          restriction_type = lookup(geo_restriction.value, "restriction_type", null)
        }

      }

    }
  }

  enabled = var.is_distribution_enabled
  is_ipv6_enabled = var.is_ipv6_enabled
  default_root_object = var.default_root_object

  aliases = [var.dns_name]

  default_cache_behavior {
    allowed_methods = var.default_cache_behavior_allowed_methods
    cached_methods = var.default_cache_behavior_cached_methods
    target_origin_id = var.origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"

    min_ttl = var.min_ttl
    default_ttl = var.default_ttl
    max_ttl = var.max_ttl
  }

  price_class = var.price_class

  tags = var.tags

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.this.arn
    ssl_support_method = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"
  }

//  dynamic "viewer_certificate" {
//    for_each = length(keys(var.viewer_certificate)) == 0 ? [] : [var.viewer_certificate]
//    content {
//      cloudfront_default_certificate = lookup(viewer_certificate.value, "cloudfront_default_certificate", null)
//      acm_certificate_arn = lookup(viewer_certificate.value, "acm_certificate_arn", aws_acm_certificate.this.arn)
//      ssl_support_method = lookup(viewer_certificate.value, "ssl_support_method", null)
//      minimum_protocol_version = lookup(viewer_certificate.value, "minimum_protocol_version", null)
//    }
//  }

}

//variable "viewer_certificate" {
//  type = any
//  default = {
//    acm_certificate_arn = aws_acm_certificate.this.arn
//    ssl_support_method = "sni-only"
//    minimum_protocol_version = ["TLSv1.2_2018"]
//  }
//  description = ""
//}


data "aws_iam_policy_document" "cf_s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${element(aws_s3_bucket.the_bucket.*.arn, 0)}/*"]

    principals {
      type        = "AWS"
      identifiers = ["${element(aws_cloudfront_origin_access_identity.origin_access_identity.*.iam_arn, 0)}"]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = ["${element(aws_s3_bucket.the_bucket.*.arn, 0)}"]

    principals {
      type        = "AWS"
      identifiers = ["${element(aws_cloudfront_origin_access_identity.origin_access_identity.*.iam_arn, 0)}"]
    }
  }
}

resource "aws_s3_bucket_policy" "buckeet_policy" {
  bucket = "${element(aws_s3_bucket.the_bucket.*.id, 0)}"
  policy = "${data.aws_iam_policy_document.cf_s3_policy.json}"
}