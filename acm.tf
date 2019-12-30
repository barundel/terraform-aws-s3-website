resource aws_acm_certificate this {
  provider = "aws.certificate"
  domain_name               = var.dns_name
  subject_alternative_names = var.subject_alternative_names
  validation_method         = var.validation_method
  tags                      = var.tags

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      "subject_alternative_names",
    ]
  }
}

resource aws_route53_record validation {
  provider = "aws.dns"
  count = var.validation_method == "DNS" && var.validate_certificate ? length(local.distinct_domain_names) : 0

  zone_id         = data.aws_route53_zone.zone[0].id
  name            = aws_acm_certificate.this.domain_validation_options.0.resource_record_name
  type            = aws_acm_certificate.this.domain_validation_options.0.resource_record_type

  ttl             = var.ttl
  allow_overwrite = var.allow_overwrite_records

  records = [
    aws_acm_certificate.this.domain_validation_options.0.resource_record_value
  ]

  depends_on = [aws_acm_certificate.this]
}

resource aws_acm_certificate_validation this {
  count                   = var.validation_method == "DNS" && var.validate_certificate ? 1 : 0
  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = aws_route53_record.validation.*.fqdn
}



locals {
  distinct_domain_names = distinct(concat([var.domain_name], [for s in var.subject_alternative_names : replace(s, "*.", "")]))
}

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