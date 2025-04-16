resource "aws_apigatewayv2_api" "etl_api" {
  name          = "etl-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "etl_stage" {
  api_id      = aws_apigatewayv2_api.etl_api.id
  name        = "prod"
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id             = aws_apigatewayv2_api.etl_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.trigger_etl.invoke_arn
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "etl_route" {
  api_id    = aws_apigatewayv2_api.etl_api.id
  route_key = "POST /trigger-etl"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

output "api_gateway_url" {
  value       = "${aws_apigatewayv2_stage.etl_stage.invoke_url}/trigger-etl"
  description = "The URL to invoke the API Gateway endpoint"
}
