resource "aws_s3_bucket" "the_bucket" {
  count = var.create_bucket ? 1 : 0

  bucket              = var.bucket_name
  acl                 = var.acl
  tags                = var.tags


  dynamic "website" {
    for_each = length(keys(var.website)) == 0 ? [] : [var.website]

    content {
      index_document           = lookup(website.value, "index_document", null)
      error_document           = lookup(website.value, "error_document", null)
      redirect_all_requests_to = lookup(website.value, "redirect_all_requests_to", null)
      routing_rules            = lookup(website.value, "routing_rules", null)
    }
  }

  dynamic "versioning" {
    for_each = length(keys(var.versioning)) == 0 ? [] : [var.versioning]

    content {
      enabled    = lookup(versioning.value, "enabled", null)
      mfa_delete = lookup(versioning.value, "mfa_delete", null)
    }
  }

//  dynamic "logging" {
//    for_each = length(keys(var.logging)) == 0 ? [] : [var.logging]
//
//    content {
//      target_bucket = logging.value.target_bucket
//      target_prefix = lookup(logging.value, "target_prefix", null)
//    }
//  }
//


  # Max 1 block - server_side_encryption_configuration
  dynamic "server_side_encryption_configuration" {
    for_each = length(keys(var.server_side_encryption_configuration)) == 0 ? [] : [var.server_side_encryption_configuration]

    content {

      dynamic "rule" {
        for_each = length(keys(lookup(server_side_encryption_configuration.value, "rule", {}))) == 0 ? [] : [lookup(server_side_encryption_configuration.value, "rule", {})]

        content {

          dynamic "apply_server_side_encryption_by_default" {
            for_each = length(keys(lookup(rule.value, "apply_server_side_encryption_by_default", {}))) == 0 ? [] : [
              lookup(rule.value, "apply_server_side_encryption_by_default", {})]

            content {
              sse_algorithm     = lookup(apply_server_side_encryption_by_default.value, "sse_algorithm", null)
              kms_master_key_id = lookup(apply_server_side_encryption_by_default.value, "kms_master_key_id", null)
            }
          }
        }
      }
    }
  }


}



output "s3_bucket_id" {
  description = "The name of the bucket."
  value       =   element(concat(aws_s3_bucket.the_bucket.*.id, list("")), 0)
}

output "s3_bucket_arn" {
  description = "The ARN of the bucket. Will be of format arn:aws:s3:::bucketname."
  value       =   element(concat(aws_s3_bucket.the_bucket.*.arn, list("")), 0)
}

output "bucket_bucket_domain_name" {
  description = "The bucket domain name. Will be of format bucketname.s3.amazonaws.com."
  value       =   element(concat(aws_s3_bucket.the_bucket.*.bucket_domain_name, list("")), 0)
}

output "bucket_bucket_regional_domain_name" {
  description = "The bucket region-specific domain name. The bucket domain name including the region name, please refer here for format. Note: The AWS CloudFront allows specifying S3 region-specific endpoint when creating S3 origin, it will prevent redirect issues from CloudFront to S3 Origin URL."
  value       =   element(concat(aws_s3_bucket.the_bucket.*.bucket_regional_domain_name, list("")), 0)
}

output "bucket_hosted_zone_id" {
  description = "The Route 53 Hosted Zone ID for this bucket's region."
  value       =   element(concat(aws_s3_bucket.the_bucket.*.hosted_zone_id, list("")), 0)
}

output "bucket_website_endpoint" {
  description = "The website endpoint, if the bucket is configured with a website. If not, this will be an empty string."
  value       =   element(concat(aws_s3_bucket.the_bucket.*.website_endpoint, list("")), 0)
}

output "bucket_website_domain" {
  description = "The domain of the website endpoint, if the bucket is configured with a website. If not, this will be an empty string. This is used to create Route 53 alias records. "
  value       =   element(concat(aws_s3_bucket.the_bucket.*.website_domain, list("")), 0)
}