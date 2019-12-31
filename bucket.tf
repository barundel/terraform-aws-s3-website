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