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

}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  count = var.create_cloudfront ? 1 : 0

  comment = "${var.origin_id}-cloudfront-access-identity"
}


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