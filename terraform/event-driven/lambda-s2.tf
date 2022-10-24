resource "aws_iam_role" "b2" {
  name = "${var.stageTwoLambdaOne}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "b2" {
  name = "${var.stageTwoLambdaOne}-role-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow",
        Action   = "logs:CreateLogGroup",
        Resource = "arn:aws:logs:${var.region}:${data.aws_caller_identity.account.account_id}:*"
      },
      {
        Effect   = "Allow",
        Action   = ["logs:CreateLogStream", "logs:PutLogEvents"],
        Resource = ["arn:aws:logs:${var.region}:${data.aws_caller_identity.account.account_id}:log-group:/aws/lambda/${var.stageTwoLambdaOne}:*"]
      },
      {
        Action   = ["sns:Publish"]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "b2" {
  role       = aws_iam_role.a2.name
  policy_arn = aws_iam_policy.a2.arn
}


data "archive_file" "b2" {
  type        = "zip"
  source_file = "${path.module}/lambdaHandlers/b2.py"
  output_path = "${path.module}/lambdaHandlers/b2.py.zip"
}

resource "aws_lambda_function" "b2" {
  filename         = data.archive_file.b2.output_path
  source_code_hash = data.archive_file.b2.output_base64sha256
  function_name    = var.stageTwoLambdaOne
  role             = aws_iam_role.b2.arn
  handler          = "b2.lambda_handler"
  runtime          = "python3.9"
  layers           = [aws_lambda_layer_version.l1.arn, aws_lambda_layer_version.l2.arn]
  timeout          = var.lambdaTimeout
  environment {
    variables = {
      snsArn = aws_sns_topic.b3.arn
    }
  }
}


data "archive_file" "b5" {
  type        = "zip"
  source_file = "${path.module}/lambdaHandlers/b5.py"
  output_path = "${path.module}/lambdaHandlers/b5.py.zip"
}

resource "aws_lambda_function" "b5" {
  filename         = data.archive_file.b5.output_path
  source_code_hash = data.archive_file.b5.output_base64sha256
  function_name    = var.stageTwoLambdaTwo
  role             = aws_iam_role.common.arn
  handler          = "b5.lambda_handler"
  runtime          = "python3.9"
  layers           = [aws_lambda_layer_version.l1.arn, aws_lambda_layer_version.l2.arn]
  timeout          = var.lambdaTimeout
  environment {
    variables = {
      metadataBucket = data.aws_s3_bucket.c1.id
      sqsUrl         = aws_sqs_queue.b4.url
    }
  }
}

resource "aws_lambda_event_source_mapping" "b5" {
  event_source_arn = aws_sqs_queue.b4.arn
  function_name    = aws_lambda_function.b5.arn
}
