provider "aws" {
  region = "${var.region}"
}

variable "account_id" {
  description = "Billing account ID"
}

variable "region" {
  description = "AWS Region"
  default = "ap-southeast-1"
}

# Name of our application
variable "application" {
  description = "Trade events"
  default = "datapipeline-kinesis-lambda-dynamodb"
}

# Name of our dynamoDB table
variable "dynamodb_name" {
  description = "Table name"
  default = "dynamodb"
}

# Name of our kinesis stream
variable "kinesis_name" {
  description = "Table name"
  default = "kinesis"
}

#Name of Lambda function
variable "function_name" {
  description = "Name of the lambda function"
  default = "lambda"
}

# =====================================
# Configuration for our kinesis service
# =====================================

resource "aws_kinesis_stream" "default" {
  name             = "${var.application}-${var.kinesis_name}"
  shard_count      = 1
  retention_period = 48
}

# ======================================
# Configuration for our dynamoDB service
# ======================================

resource "aws_dynamodb_table" "default" {
  
  name = "${var.application}-${var.dynamodb_name}"
  
  read_capacity  = 5
  write_capacity = 5

  hash_key = "date"

  attribute = [{
    name = "date"
    type = "N"
  }]

}

# ====================================
# Configuration for our lambda service
# ====================================

resource "aws_iam_role" "default" {

  name = "${var.application}-${var.function_name}-iam-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
  EOF

}

#Attach kinesis access policy to iam role
resource "aws_iam_role_policy" "kinesis-access" {
  
  name = "${var.application}-${var.function_name}-kinesis-access-policy"
  role = "${aws_iam_role.default.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "kinesis:DescribeStream",
        "kinesis:ListStreams",
        "kinesis:GetShardIterator",
        "kinesis:GetRecords",
        "kinesis:ListTagsForStream"
      ],
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Sid": ""
    }
  ]
}
  EOF

}

#Attach dynamodb access policy to iam role
resource "aws_iam_role_policy" "dynamodb-access" {

  name = "${var.application}-${var.function_name}-dynamodb-access-policy"
  role = "${aws_iam_role.default.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["dynamodb:*"],
      "Resource": "arn:aws:dynamodb:${var.region}:${var.account_id}:table/${var.application}-${var.dynamodb_name}"
    }
  ]
}
  EOF

}

#Attach kinesis access policy to iam role
resource "aws_iam_role_policy" "logs-access" {
  
  name = "${var.application}-${var.function_name}-logs-access-policy"
  role = "${aws_iam_role.default.id}"

  policy = <<EOF
{
  "Statement": [
    {
          "Effect": "Allow",
          "Action": [
              "logs:*"
          ],
          "Resource": "arn:aws:logs:*:*:*"
    }
  ]
}
  EOF

}

resource "aws_lambda_function" "default" {
  filename         = "${var.function_name}.zip"
  function_name    = "${var.application}-${var.function_name}"
  role             = "${aws_iam_role.default.arn}"
  timeout          = 60
  memory_size      = 1024
  handler          = "${var.function_name}.lambda_handler"
  runtime          = "python3.6"
}

resource "aws_lambda_event_source_mapping" "kinesis" {
  batch_size        = 50
  event_source_arn  = "${aws_kinesis_stream.default.arn}"
  enabled           = true
  function_name     = "${aws_lambda_function.default.arn}"
  starting_position = "TRIM_HORIZON"
}

