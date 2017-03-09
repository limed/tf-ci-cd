resource "aws_iam_role" "codebuild_role" {
  name = "${var.instance_name}-codebuild-role"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "codebuild.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
}
EOF
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name        = "${var.instance_name}-codebuild-policy"
  role        = "${aws_iam_role.codebuild_role.id}"
  policy      = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Resource": "arn:aws:logs:*:*:*",
        "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
      },
      {
        "Effect": "Allow",
        "Resource": "${aws_s3_bucket.artifact-store.arn}/*",
        "Action": [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject"
        ]
      }
    ]
}
POLICY
}

resource aws_codebuild_project "project" {
  name         = "${var.instance_name}"
  description  = "Codebuild project for ${var.instance_name}"
  timeout      = "60"
  service_role = "${aws_iam_role.codebuild_role.arn}"

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/golang:1.7.3"
    type         = "LINUX_CONTAINER"
  }

  source {
    type     = "GITHUB"
    location  = "https://github.com/${var.github_user}/${var.github_repo}"
  }

  tags {
    "Name"        = "${var.instance_name}"
    "GithubRepo"  = "https://github.com/${var.github_user}/${var.github_repo}"
  }
}

