data "aws_route53_zone" "zone" {
  provider = "aws.dns"
  count = var.create_dns_record ? 1 : 0
  name  = var.domain_lookup
}