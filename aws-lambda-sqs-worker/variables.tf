variable "aws_access_key" {
  type        = "string"
  description = "The access key for the AWS account you wish to deploy to."
}

variable "aws_secret_key" {
  type        = "string"
  description = "The secret key for the AWS account you wish to deploy to."
}

variable "aws_region" {
  type        = "string"
  default     = "us-west-2"
  description = "The availability zone that we will be deploying to."
}

variable "prefix" {
  type        = "string"
  description = "The prefix for the resources created by this module."
}

variable "project_tag" {
  type        = "string"
  default     = ""
  description = "When supplied, a Project tag will be added to resources that support tags."
}

variable "use_dead_letter_queue" {
  default     = true
  description = "When true, a dead letter queue will be made for the live queue to put messages that have used all of their max retries."
}

variable "max_retries" {
  type        = "string"
  default     = 5
  description = "The maximum number of attempts that a message in the live queue will be tried before being moved to the dead letter queue."
}

variable "lambda_env_vars" {
  type        = "map"
  default     = {}
  description = "The environment variables that you want to pass to the worker Lambda created by this module."
}
