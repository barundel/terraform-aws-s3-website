provider "aws" {
  // Cloudfront is global cert needs to be in us-east-1
  alias = "certificate"
}

provider "aws" {
  // if you manage DNS in a central AWS account.
  alias = "dns"
}