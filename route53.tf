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

data "aws_route53_zone" "zone" {
  provider = "aws.dns"
  count = var.create_dns_record ? 1 : 0
  name  = var.domain_lookup
}

resource "aws_route53_record" "dns_record" {
  provider = "aws.dns"
  count = var.create_dns_record ? 1 : 0

  zone_id = data.aws_route53_zone.zone[0].id
  name    = var.dns_name

  type = "A"

  alias {
    name                   = element(aws_cloudfront_distribution.main.*.domain_name, 0)
    zone_id                = element(aws_cloudfront_distribution.main.*.hosted_zone_id, 0)
    evaluate_target_health = false
  }
}