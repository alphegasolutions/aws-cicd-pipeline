resource "aws_codebuild_project" "plan" {
  name         = "plan"
  description  = "Terraform plan stage"
  service_role = aws_iam_role.build-role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "hashicorp/terraform:0.14.3"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"
#    registry_credential {
#      credential = ""
#      credential_provider = ""
#    }
  }

  source {
    type = "CODEPIPELINE"
    buildspec = file("buildspec/plan.yml")
  }
}

resource "aws_codebuild_project" "apply" {
  name         = "apply"
  description  = "Terraform apply stage"
  service_role = aws_iam_role.build-role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "hashicorp/terraform:0.14.3"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"
#    registry_credential {
#      credential = ""
#      credential_provider = ""
#    }
  }

  source {
    type = "CODEPIPELINE"
    buildspec = file("buildspec/apply.yml")
  }
}

resource "aws_codepipeline" "pipeline" {

  name     = "cicd"
  role_arn = aws_iam_role.pipeline-role.arn

  artifact_store {
    type     = "S3"
    location = aws_s3_bucket.pipeline_artifacts.id
  }

  stage {
    name = "Source"
    action {
        name             = "Source"
        category         = "Source"
        owner            = "AWS"
        provider         = "CodeStarSourceConnection"
        version          = "1"
        output_artifacts = ["tf-code"]
        configuration    = {
            FullRepositoryId     = "alphegasolutions/aws-cicd-pipeline"
            BranchName           = "main"
            ConnectionArn        = var.codestar_connector_credentials
            OutputArtifactFormat = "CODE_ZIP"
        }
    }
  }

  stage {
    name = "Plan"
    action {
        name             = "Build"
        category         = "Build"
        provider         = "CodeBuild"
        version          = "1"
        owner            = "AWS"
        input_artifacts  = [ "tf-code" ]
        configuration    = {
          ProjectName = "plan"
        }
    }
  }
}