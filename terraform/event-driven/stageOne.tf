resource "aws_s3_bucket" "s1" {
  bucket = "stage-a1-bucket-s3"
  tags = {
    Name        = "a1-bucket-s3"
    Environment = "development"
  }
}

data "archive_file" "s1" {
  type        = "zip"
  source_file = "${path.module}/stageOne/main.py"
  output_path = "${path.module}/stageOne/main.py.zip"
}

resource "aws_iam_role" "s1" {
  name = "stage-a2-lambda-lambda-role"
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

resource "aws_iam_policy" "s1" {
  name = "stage-a2-lambda-lambda-role-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["sns:*"]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s1" {
  role       = aws_iam_role.s1.name
  policy_arn = aws_iam_policy.s1.arn
}
resource "aws_lambda_function" "s1" {
  filename      = "${path.module}/stageOne/main.py.zip"
  function_name = "stage-a2-lambda"
  role          = aws_iam_role.s1.arn
  handler       = "main.lambda_handler"
  runtime       = "python3.9"
  environment {
    variables = {
      snsArn = aws_sns_topic.s1.arn
    }
  }
}

resource "aws_sns_topic" "s1" {
  name                        = "a3-sns-topic.fifo"
  fifo_topic                  = true
  content_based_deduplication = true
}


resource "aws_s3_bucket_notification" "s1" {
  bucket = aws_s3_bucket.s1.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.s1.arn
    events              = ["s3:ObjectCreated:*"]
    id                  = "stage-a2-s3-to-lambda-notofcation"
  }
}

resource "aws_sqs_queue" "s1" {
  name                  = "a3-sqs-queue.fifo"
  fifo_queue            = true
  deduplication_scope   = "messageGroup"
  fifo_throughput_limit = "perMessageGroupId"
}
resource "aws_sqs_queue_policy" "s1" {
  queue_url = aws_sqs_queue.s1.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Id" : "sqspolicy",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "sns.amazonaws.com"
        },
        "Action" : "SQS:SendMessage",
        "Resource" : "${aws_sqs_queue.s1.arn}",
        "Condition" : {
          "ArnLike" : {
            "aws:SourceArn" : "${aws_sns_topic.s1.arn}"
          }
        }
      }
    ]
  })
}


