output "live_queue_url" {
  value = "${aws_sqs_queue.live_queue.id}"
}

output "live_queue_arn" {
  value = "${aws_sqs_queue.live_queue.arn}"
}

output "dead_queue_url" {
  value = "${aws_sqs_queue.dead_letter_queue.id}"
}

output "dead_queue_arn" {
  value = "${aws_sqs_queue.dead_letter_queue.arn}"
}

output "lambda_iam_arn" {
  value = "${aws_iam_role.iam_for_lambda.arn}"
}

output "lambda_iam_name" {
  value = "${aws_iam_role.iam_for_lambda.name}"
}

output "lambda_arn" {
  value = "${aws_lambda_function.queue_worker.arn}"
}

output "lambda_invocation_arn" {
  value = "${aws_lambda_function.queue_worker.invoke_arn}"
}

output "lambda_qualified_arn" {
  value = "${aws_lambda_function.queue_worker.qualified_arn}"
}
