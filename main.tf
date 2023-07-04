provider "aws" {
  region = "eu-west-3"
}

resource "aws_lambda_function" "hello_world_x86" {
  filename         = "hellox86.zip"
  function_name    = "helloWorldx86"
  architectures    = ["x86_64"]
  role             = aws_iam_role.lambda_role.arn
  handler          = "hello"
  runtime          = "go1.x"
  source_code_hash = filebase64sha256("hellox86.zip")
}

resource "aws_cloudwatch_log_group" "x86_lambda_logs" {
  name              = "/aws/lambda/helloWorldx86"
  retention_in_days = 1
}

resource "aws_lambda_function" "hello_world_arm64" {
  filename         = "bootstrap.zip"
  function_name    = "helloWorldarm64"
  architectures    = ["arm64"]
  role             = aws_iam_role.lambda_role.arn
  handler          = "bootstrap"
  runtime          = "provided.al2"
  source_code_hash = filebase64sha256("bootstrap.zip")
}

resource "aws_cloudwatch_log_group" "arm64_lambda_logs" {
  name              = "/aws/lambda/helloWorldarm64"
  retention_in_days = 1
}

resource "aws_iam_role" "lambda_role" {
  name = "lambdaRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]
}

resource "aws_lambda_permission" "apigwx86" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hello_world_x86.arn
  principal     = "apigateway.amazonaws.com"
}

resource "aws_lambda_permission" "apigwarm64" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hello_world_arm64.arn
  principal     = "apigateway.amazonaws.com"
}

resource "aws_apigatewayv2_api" "api" {
  name          = "helloWorldAPI"
  protocol_type = "HTTP"

}

resource "aws_cloudwatch_log_group" "api_logs" {
  name              = "/aws/apigateway/helloWorldAPI"
  retention_in_days = 1
}

resource "aws_apigatewayv2_integration" "x86_lambda_integration" {
  api_id             = aws_apigatewayv2_api.api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.hello_world_x86.invoke_arn
  integration_method = "POST"
}

resource "aws_apigatewayv2_integration" "arm64_lambda_integration" {
  api_id             = aws_apigatewayv2_api.api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.hello_world_arm64.invoke_arn
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "x86_lambda_route" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "GET /x86"
  target    = "integrations/${aws_apigatewayv2_integration.x86_lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "arm64_lambda_route" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "GET /arm64"
  target    = "integrations/${aws_apigatewayv2_integration.arm64_lambda_integration.id}"
}

output "api_endpoint" {
  value = aws_apigatewayv2_api.api.api_endpoint
}

resource "aws_apigatewayv2_stage" "api_stage" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = "dev"
  auto_deploy = true
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_logs.arn
    format          = "{\"requestId\":\"$context.requestId\",\"ip\":\"$context.identity.sourceIp\",\"user\":\"$context.identity.user\",\"method\":\"$context.httpMethod\",\"path\":\"$context.path\",\"statusCode\":\"$context.status\",\"userAgent\":\"$context.identity.userAgent\",\"integrationLatency\":\"$context.integrationLatency\",\"responseLatency\":\"$context.responseLatency\",\"integrationStatus\":\"$context.integrationStatus\",\"responseLength\":\"$context.responseLength\"}"
  }
}