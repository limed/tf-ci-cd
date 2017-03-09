resource aws_s3_bucket "artifact-store" {
	bucket	= "${var.instance_name}-artifact-${random_id.uuid.hex}"
	acl			= "private"
}

resource "aws_iam_role" "codepipeline-role" {
	name	= "${var.instance_name}-codepipeline-role"
	assume_role_policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Principal": {
				"Service": "codepipeline.amazonaws.com"
			},
			"Action": "sts:AssumeRole"
		}
	]
}
EOF
}

resource aws_iam_role_policy "codepipeline-policy" {
  name  = "${var.instance_name}-service-policy"
  role  = "${aws_iam_role.codepipeline-role.id}"

  policy  = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
				"s3:PutObject",
				"s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning"
      ],
			"Resource": [
        "${aws_s3_bucket.artifact-store.arn}",
        "${aws_s3_bucket.artifact-store.arn}/*"
      ]
    },
    {
      "Action": [
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild"
      ],
      "Resource": "*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource aws_codepipeline "codepipeline" {
	name			= "${var.instance_name}"
	role_arn  = "${aws_iam_role.codepipeline-role.arn}"

	artifact_store {
  	location 	= "${aws_s3_bucket.artifact-store.bucket}"
		type			= "S3"
	}

	stage {
  	name	= "Source"
		action {
    	name			        = "Source"
			category	        = "Source"
			owner			        = "ThirdParty"
			provider	        = "GitHub"
			version		        = "1"
      output_artifacts  = [ "${var.instance_name}" ]

			configuration {
      	Owner		    = "${var.github_user}"
				Repo		    = "${var.github_repo}"
				Branch	    = "${var.github_branch}"
        OAuthToken  = "${var.github_token}"
			}
		}
	}

  stage {
  	name = "Build"

    action {
      name              = "Build"
      category          = "Build"
      owner             = "AWS"
      provider          = "CodeBuild"
      input_artifacts   = [ "${var.instance_name}" ]
      output_artifacts  = [ "${var.instance_name}-build-output" ]
      version           = "1"

      configuration {
        ProjectName = "${aws_codebuild_project.project.name}"
      }
		}
	}
}
