
locals {
  base_path = "${path.module}/src"
}

data "template_file" "this" {
  template = "${file("${local.base_path}/params.json")}"

  vars = {
    REDIRECT_URL = var.redirect_url
  }
}

resource "local_file" "params" {
  content = data.template_file.this.rendered
  filename = "${local.base_path}/.archived/params.json"
}

data "local_file" "mainjs" {
  filename = "${local.base_path}/main.js"
}

resource "local_file" "mainjs" {
  content = data.local_file.mainjs.content
  filename = "${local.base_path}/.archived/main.js"
}

data "archive_file" "this" {
  depends_on = [
    local_file.params,
    local_file.mainjs
  ]

  type = "zip"
  output_path = "${local.base_path}/.archived.zip"
  source_dir = "${local.base_path}/.archived"
}

resource "aws_lambda_function" "this" {
  description = "Lambda to route CloudFront origin request per device"
  role = aws_iam_role.this.arn
  runtime = "nodejs10.x"

  filename = data.archive_file.this.output_path
  source_code_hash = data.archive_file.this.output_base64sha256

  function_name = var.name
  handler = "main.handler"

  timeout = 10
  memory_size = 128
  publish = true
}

