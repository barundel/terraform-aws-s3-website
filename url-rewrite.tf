

locals {
  function_name = "${replace(var.dns_name, ".", "-")}"
  archive_file_dir = "${path.module}/lib/"

}


variable "create_rewrite_lambda" {
  default = true
}

data "archive_file" "zip_file" {
  type        = "zip"
  output_path = "${local.archive_file_dir}/${local.function_name}.zip"
  source_file = "${local.archive_file_dir}/rewrite_url_code.js"
}


resource "aws_iam_role" "lambda_role" {
  name = "${local.function_name}-Role"
  assume_role_policy = data.aws_iam_policy_document.lambda_trust_profile.json
}

resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "function" {
  count = "${var.create_rewrite_lambda ? 1 : 0}"
  provider = "aws.certificate"
  filename      = "${local.archive_file_dir}/${local.function_name}.zip"
  function_name = "${local.function_name}"
  handler       = "rewrite_url_code.handler"
  role          = "${aws_iam_role.lambda_role.arn}"
  runtime       = "nodejs8.10"
  timeout       = 5
  publish = true

  tags = var.tags
}
