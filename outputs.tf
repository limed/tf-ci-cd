output codebuild_role_id {
  value = "${aws_iam_role.codepipeline_role.id}"
}

output codepipeline_role_id {
  value = "${aws_iam_role.codepipeline-role.id}"
}

output codebuild_role_arn {
  value = "${aws_iam_role.codebuild_role.arn}"
}

output codepipeline_role_arn {
  value = "${aws_iam_role.codepipeline-role.arn}"
}
