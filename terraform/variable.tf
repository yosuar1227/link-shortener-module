variable "hasKeyForDynamoTable" {
  type = string
  default = "uuid"
}

variable "rangeKeyForDynamoTable" {
  type = string
  default = "linkCode"
}

variable "defaultBillingModeDynamoDb" {
  type = string
  default = "PROVISIONED"
  description = "default billing mode value for dynamo db"
}

variable "NUMBER_20" {
  type = number
  default = 20
}

variable "defaultRunTime" {
  type = string
  default = "nodejs20.x"
  description = "default run time for this project"
}


variable "NONE_AUTH" {
  type = string
  default = "NONE"
}

variable "AWS_PROXY" {
  type = string
  default = "AWS_PROXY"
}

variable "HTTP_METHOD_POST" {
  type = string
  default = "POST"
}

variable "AMAZON_API_COM" {
  type = string
  default = "apigateway.amazonaws.com"
  description = "principal url for apigateway"
}

variable "defaultPolicyArn" {
  type = string
  default = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  description = "default policy arn for this project and lambdas"
}

variable "shortenLinklambda" {
  type = string
  default = "shorten-link"
  description = "variable just for the nama of the shorten link lambda"
}

variable "STAGE" {
  type = string
  default = "dev"
}