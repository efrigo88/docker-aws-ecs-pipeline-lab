data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.root}/build/trigger_etl.py"
  output_path = "${path.root}/build/trigger_etl.zip"
}

resource "aws_lambda_function" "trigger_etl" {
  function_name    = "trigger-etl"
  description      = "Trigger ETL task"
  architectures    = ["x86_64"]
  filename         = data.archive_file.lambda_zip.output_path
  role             = aws_iam_role.lambda_role.arn
  handler          = "trigger_etl.handler"
  runtime          = "python3.10"
  package_type     = "Zip"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      ECS_CLUSTER         = aws_ecs_cluster.data_pipeline.name
      ECS_TASK_DEFINITION = aws_ecs_task_definition.etl_task.arn
      SUBNET_IDS          = join(",", aws_subnet.private[*].id)
      SECURITY_GROUP_ID   = aws_security_group.ecs_tasks.id
    }
  }
}

# Lambda permission to be invoked by API Gateway
resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.trigger_etl.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.etl_api.execution_arn}/*/*"
}
