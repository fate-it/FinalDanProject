variable "name" {
}
variable "vpc_id" {
}
variable "subnets_ids" {
}
variable "tags" {
}
variable "region" {
  description = "aws region"
  default     = "eu-central-1"
}

### Backend vars
variable "iam_profile" {
  description = "Profile of aws creds"
  default     = null
}

variable "zone_name" {
}
