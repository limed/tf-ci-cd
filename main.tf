provider "aws" {
  region  = "${var.aws_region}"
}

resource random_id "uuid" {

  byte_length = 8

  keepers = {
    instance_name = "${var.instance_name}"
  }
}
