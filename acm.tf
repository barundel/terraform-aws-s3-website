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
  provider = "aws.certificate"
  count                   = var.validation_method == "DNS" && var.validate_certificate ? 1 : 0
  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = aws_route53_record.validation.*.fqdn
}



locals {
  distinct_domain_names = distinct(concat([var.domain_name], [for s in var.subject_alternative_names : replace(s, "*.", "")]))
}

