## ACM Vars
variable "domain_name" {
  description = "A domain name for which the certificate should be issued"
  type        = string
  default     = ""
}

variable "subject_alternative_names" {
  description = "A list of domains that should be SANs in the issued certificate"
  type        = list(string)
  default     = []
}

variable "validation_method" {
  description = "Which method to use for validation. DNS or EMAIL are valid, NONE can be used for certificates that were imported into ACM and then into Terraform."
  type        = string
  default     = "DNS"
}

variable "zone_id" {
  description = "The ID of the hosted zone to contain this record."
  type        = string
  default     = ""
}

variable "ttl" {
  description = "The TTL of the record."
  type        = number
  default     = 60
}

variable "validate_certificate" {
  description = "Whether or not certificate should be validated"
  type        = bool
  default     = true
}

variable "allow_overwrite_records" {
  description = "Allow creation of this record in Terraform to overwrite an existing record, if any."
  type        = bool
  default     = true
}

## S3 Vars
variable "create_bucket" {
  description = "True or false to create the bucket, defaults to true"
  default = true
  type = any
}

variable "bucket_name" {
  description = "Name of the S3 website bucket you want to create."
  default = ""
}

variable "versioning" {
  description = "Map of config for enabling versioning, defaults to enabled"
  default = {
    enabled = true
  }
}

variable "website" {
  description = "Website conflig block, index and error doc etc"
  default = {}
  type = any
}

variable "server_side_encryption_configuration" {
  description = "encryption conflig block, aes, kms etc"
  default = {}
  type = any
}

variable "acl" {
  description = "The bucket ACL to apply. Defaults to private"
  default = "private"
}

variable "tags" {
  description = "Map of tags to apply to the resource"
  default = {}
}

## CloudFront Vars
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

## Route53 Vars
variable "create_dns_record" {
  // This may fuck you up later ben
  description = "True False on if to create dns record that points to cloudfront, defaults to true."
  default = true
}

variable "dns_name" {
  description = "Custom DNS name, works with var.create_dns_record or standalone"
}

variable "domain_lookup" {
  description = "Domain to use as a data lookup for the hosted zone ID."
  default = ""
}