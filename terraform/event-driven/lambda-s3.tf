data "archive_file" "c2" {
  type        = "zip"
  source_file = "${path.module}/lambdaHandlers/c2.py"
  output_path = "${path.module}/lambdaHandlers/c2.py.zip"
}

resource "aws_lambda_function" "c2" {
  filename      = "${path.module}/lambdaHandlers/c2.py.zip"
  function_name = "op-c2-lambda"
  role          = aws_iam_role.common.arn
  handler       = "c2.lambda_handler"
  runtime       = "python3.9"
  layers = [aws_lambda_layer_version.l1.arn, aws_lambda_layer_version.l2.arn]
  environment {
    variables = {
      snsArn = aws_sns_topic.c3.arn
    }
  }
}


data "archive_file" "c6" {
  type        = "zip"
  source_file = "${path.module}/lambdaHandlers/c6.py"
  output_path = "${path.module}/lambdaHandlers/c6.py.zip"
}

resource "aws_lambda_function" "c6" {
  filename      = "${path.module}/lambdaHandlers/c6.py.zip"
  function_name = "op-c6-lambda"
  role          = aws_iam_role.common.arn
  handler       = "c6.lambda_handler"
  runtime       = "python3.9"
  layers = [aws_lambda_layer_version.l1.arn, aws_lambda_layer_version.l2.arn]
  environment {
    variables = {
      apiGatewayUrl     = aws_api_gateway_deployment.get.invoke_url
      sqsUrl            = aws_sqs_queue.c4.url
      apiGatewayId      = aws_api_gateway_rest_api.api.id
      originBucketName  = aws_s3_bucket.c1.bucket  
      success_destination_bucket_name = aws_s3_bucket.d1.bucket   
      failed_destination_bucket_name  = aws_s3_bucket.d2.bucket
      alertSqsQueueURL  = var.alertSqsQueueURL                  
    }
  }
}