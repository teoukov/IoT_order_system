
resource "aws_lambda_function" "order_handler_lambda" {
  filename          = "order_handler.zip"
  function_name     = "order_handler"
  role              = "arn:aws:iam::253712699852:role/lambda_basic_execution"
  handler           = "order_handler.lambda_handler"
  runtime           = "python3.6"
  source_code_hash  = "${base64sha256(file("order_handler.zip"))}"
}

resource "aws_lambda_function" "car_caller_lambda" {
  filename          = "car_caller.zip"
  function_name     = "car_caller"
  role              = "arn:aws:iam::253712699852:role/lambda_basic_execution"
  handler           = "car_caller.lambda_handler"
  runtime           = "python3.6"
  source_code_hash  = "${base64sha256(file("car_caller.zip"))}"
}

resource "aws_sns_topic" "orders_sns_topic" {
  name              = "orders"
}

resource "aws_sns_topic_subscription" "sns_to_car_caller"{
  topic_arn         = "${aws_sns_topic.orders_sns_topic.arn}"
  protocol          = "lambda"
  endpoint          = "${aws_lambda_function.car_caller_lambda.arn}"
}

resource "aws_iot_topic_rule" "iot_to_order_handler_rule" {
  name              = "iot_to_order_handler"
  description       = "Rule that manages IoT data by transporting it to the orders lambda function"
  enabled           = true
  sql               = "SELECT * FROM 'cars/calls'"
  sql_version       = "2015-10-08"

  lambda {
    function_arn    = "${aws_lambda_function.order_handler_lambda.arn}"
  }
}