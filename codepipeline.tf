resource "aws_codepipeline" "pipeline" {
  name     = "JavaAppPipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.BuildArtifacts1.bucket
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]
      configuration = {
        Owner      = "PrakashRajugithub"
        Repo       = "AWS_DevOps"
        Branch     = "main"
        OAuthToken = "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"
      }
    }
  }

  stage {
    name = "Build"
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      configuration = {
        ProjectName = aws_codebuild_project.build_project.name
      }
    }
  }

  stage {
    name = "Deploy"
    action {
      name             = "Deploy"
      category         = "Deploy"
      owner            = "AWS"
      provider         = "CodeDeploy"
      version          = "1"
      input_artifacts  = ["build_output"]
      configuration = {
        ApplicationName     = aws_codedeploy_app.java_app.name
        DeploymentGroupName = aws_codedeploy_deployment_group.JavaApp.app_name
      }
    }
  }
}
