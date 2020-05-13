variable "region" {
  default = "us-east-1"
}

variable "root_domain_name" {
  default = "kan.sh"
}

variable "www_domain_name" {
  default = "www.kan.sh"
}

variable "dev_domain_name" {
  default = "dev.kan.sh"
}

data "aws_route53_zone" "hosted_zone" {
  name = var.root_domain_name
}

