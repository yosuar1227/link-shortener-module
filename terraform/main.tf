//tf code here..
resource "aws_dynamodb_table" "ShortLinkTable" {
  name           = "short-link-table"
  billing_mode   = var.defaultBillingModeDynamoDb
  read_capacity  = var.NUMBER_20
  write_capacity = var.NUMBER_20
  hash_key       = var.hasKeyForDynamoTable
  range_key      = var.rangeKeyForDynamoTable

  attribute {
    name = var.hasKeyForDynamoTable
    type = "S"
  }
  attribute {
    name = var.rangeKeyForDynamoTable
    type = "S"
  }

  lifecycle {
    prevent_destroy = true
  }
}

//LAMBDA SHORTEN LINK
resource "aws_lambda_function" "shortenLinkLambda" {
    filename = data.archive_file.shortenLinkLambda.output_path
    function_name = var.shortenLinklambda
    handler = "${var.shortenLinklambda}.handler"
    runtime = var.defaultRunTime
    timeout = 900
    memory_size = 256
    role = aws_iam_role.shortenLinkRole.arn
    source_code_hash = data.archive_file.shortenLinkLambda.output_base64sha256
    
    environment {
      variables = {
        ShortLinkTable: aws_dynamodb_table.ShortLinkTable.name
      }
    }

    depends_on = [ 
        aws_iam_role_policy_attachment.attachForShortenLink,
        data.archive_file.shortenLinkLambda
    ]
}
//POLICY
resource "aws_iam_role_policy" "shortenLinkPolicy" {
  name = "${var.shortenLinklambda}-policy"
  policy = data.aws_iam_policy_document.lambda_shorten_link_execution.json
  role = aws_iam_role.shortenLinkRole.id
}
//ROLE
resource "aws_iam_role" "shortenLinkRole" {
  name = "${var.shortenLinklambda}-execution-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}
//ATTACHMENT
resource "aws_iam_role_policy_attachment" "attachForShortenLink" {
  role = aws_iam_role.shortenLinkRole.name
  policy_arn = var.defaultPolicyArn
}
//------------GATEWAY FOR SHORTEN LINK -----------
resource "aws_api_gateway_rest_api" "shortenLinkGtw" {
  name = "${var.shortenLinklambda}RestApi"
  description = "rest api related for shorten link lambda"
}
//shorten FOR ROOT PATH
resource "aws_api_gateway_resource" "shortenLinkGtwResource" {
  rest_api_id = aws_api_gateway_rest_api.shortenLinkGtw.id
  parent_id = aws_api_gateway_rest_api.shortenLinkGtw.root_resource_id
  path_part = "shorten"
}
//METHOD
resource "aws_api_gateway_method" "shortenLinkGtwMethod" {
  rest_api_id = aws_api_gateway_resource.shortenLinkGtwResource.id
  resource_id = aws_api_gateway_resource.shortenLinkGtwResource.id
  http_method = var.HTTP_METHOD_POST
  authorization = var.NONE_AUTH
}
//CONECTING LAMBDA WITH GATEWAY
resource "aws_api_gateway_integration" "lmbGtwShortenLinkIntegration" {
  rest_api_id = aws_api_gateway_rest_api.shortenLinkGtw.id
  resource_id = aws_api_gateway_resource.shortenLinkGtwResource.id
  http_method = aws_api_gateway_method.shortenLinkGtwMethod.http_method
  integration_http_method = var.HTTP_METHOD_POST
  type = var.AWS_PROXY
  uri = aws_lambda_function.shortenLinkLambda.invoke_arn
}
//PERMISSIONS
resource "aws_lambda_permission" "shortenLinkGtwPermissions" {
    statement_id  = "AllowExecutionFromAPIGateway"
    action        = "lambda:InvokeFunction"
    function_name = var.shortenLinklambda
    principal = var.AMAZON_API_COM
    source_arn = "${aws_api_gateway_rest_api.shortenLinkGtw.execution_arn}/*/${var.HTTP_METHOD_POST}/${aws_api_gateway_resource.shortenLinkGtwResource.path_part}"
    depends_on = [ 
        aws_lambda_function.shortenLinkLambda
    ]
}
//DEPLOY
resource "aws_api_gateway_deployment" "shortenLinkGtwDeploy" {
  rest_api_id = aws_api_gateway_rest_api.shortenLinkGtw.id
  depends_on = [ 
    aws_api_gateway_integration.lmbGtwShortenLinkIntegration,
    aws_lambda_permission.shortenLinkGtwPermissions
    ]
}
//STAGE 
resource "aws_api_gateway_stage" "shortenLinkGtwStage" {
  deployment_id = aws_api_gateway_deployment.shortenLinkGtwDeploy.id
  rest_api_id = aws_api_gateway_rest_api.shortenLinkGtw.id
  stage_name = var.STAGE
}
//OUTPUT URL
output "shortenLinkGtwUrl" {
  value = "${aws_api_gateway_stage.shortenLinkGtwStage.invoke_url}/${aws_api_gateway_resource.shortenLinkGtwResource.path_part}"
}
