data "aws_route53_zone" "zone" {
  provider = "aws.dns"
  count = var.create_dns_record ? 1 : 0
  name  = var.domain_lookup
}

data "aws_iam_policy_document" "lambda_trust_profile" {
  statement {
    sid = "LambdaServiceTrust"

    principals {
      type = "Service"

      identifiers = [
        "lambda.amazonaws.com",
        "edgelambda.amazonaws.com"
      ]
    }

    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]
  }
}





