resource "aws_iam_role" "pipeline-role" {
  name = "pipeline-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "pipeline-policies" {
  statement {
    sid = ""
    effect = "Allow"
    actions = ["codestar-connections:UseConnection"]
    resources = ["*"]
  }

  statement {
    sid = ""
    effect = "Allow"
    actions = [
        "cloudwatch:*", 
        "s3:*", 
        "codebuild:*"
    ]
    resources = [ "*" ]
  }
}

resource "aws_iam_policy" "pipeline-policy" {
  name = "pipeline-policy"
  path = "/"
  description = "Pipeline Policy"
  policy = data.aws_iam_policy_document.pipeline-policies.json
}

resource "aws_iam_role_policy_attachment" "pipeline-attachment" {
  policy_arn = aws_iam_policy.pipeline-policy.arn
  role = aws_iam_role.pipeline-role.id
}

resource "aws_iam_role" "build-role" {
  name = "build-role"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "codebuild.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
}
EOF

}

data "aws_iam_policy_document" "build-policies" {
  
  statement {
    sid = ""
    effect = "Allow"
    actions = [
      "logs:*",
      "s3:*",
      "codebuild:*",
      "iam:*"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "build-policy" {
  name = "build-policy"
  path = "/"
  description = "Codebuild policy"
  policy = data.aws_iam_policy_document.build-policies.json
}

resource "aws_iam_role_policy_attachment" "build-attachment" {
  policy_arn = aws_iam_policy.build-policy.arn
  role       = aws_iam_role.build-role.id
}

resource "aws_iam_role_policy_attachment" "build-pu-attachment" {
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
  role       = aws_iam_role.build-role.id
}