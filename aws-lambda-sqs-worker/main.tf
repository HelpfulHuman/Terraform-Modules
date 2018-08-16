locals {
  prefix = "${local.prefix}_${terraform.workspace}"
}

resource "aws_sqs_queue" "dead_letter_queue" {
  name  = "${local.prefix}_dead_letters"
  count = "${var.use_dead_letter_queue ? 1 : 0}"

  tags {
    Environment = "${terraform.workspace}"
    Project     = "${var.project_tag}"
  }
}

# TODO: support the use_dead_letter_queue variable by disabling redrive_policy when false
resource "aws_sqs_queue" "live_queue" {
  name = "${local.prefix}_live_queue"

  redrive_policy = <<EOF
{
  "maxReceiveCount": ${var.max_retries},
  "deadLetterTargetArn": "${aws_sqs_queue.dead_letter_queue.arn}"
}
EOF

  tags {
    Environment = "${terraform.workspace}"
    Project     = "${var.project_tag}"
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "${local.prefix}_queue_lambda"

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
}

resource "aws_iam_policy" "lambda_logging_policy" {
  name        = "${local.prefix}_lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda."

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = "${aws_iam_role.iam_for_lambda.name}"
  policy_arn = "${aws_iam_policy.lambda_logging_policy.arn}"
}

resource "aws_iam_policy" "lambda_sqs_policy" {
  name        = "${local.prefix}_lambda_sqs_consumer"
  path        = "/"
  description = "IAM policy for allowing Lambdas to work with SQS."

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "sqs:DeleteMessage",
        "sqs:ChangeMessageVisibility",
        "sqs:ReceiveMessage",
        "sqs:GetQueueAttributes"
      ],
      "Resource": "${aws_sqs_queue.live_queue.arn}",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_sqs_binding" {
  role       = "${aws_iam_role.iam_for_lambda.name}"
  policy_arn = "${aws_iam_policy.lambda_sqs_policy.arn}"
}

resource "aws_lambda_function" "queue_worker" {
  function_name    = "${local.prefix}_queue_worker"
  filename         = "artifacts/import_worker.zip"
  role             = "${aws_iam_role.iam_for_lambda.arn}"
  handler          = "import_worker"
  source_code_hash = "${base64sha256(file("artifacts/import_worker.zip"))}"
  runtime          = "go1.x"

  tags {
    Environment = "${terraform.workspace}"
    Project     = "${var.project_tag}"
  }

  environment {
    variables = "${var.lambda_env_vars}"
  }
}
