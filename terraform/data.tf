data "archive_file" "shortenLinkLambda" {
  type        = "zip"
  source_file = "${path.module}/../app/dist/${var.shortenLinklambda}.js"
  output_path = "${path.module}/files/lambda_register_user.zip"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda_shorten_link_execution" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:PutItem",
      "dynamodb:GetItem"
    ]
    resources = [
      aws_dynamodb_table.ShortLinkTable.arn
    ]
  }
}
