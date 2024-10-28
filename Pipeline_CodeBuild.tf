resource "aws_codebuild_project" "build_project" {
  name = "BuildJavaApp"
  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "S3"
    location = aws_s3_bucket.BuildArtifacts.bucket
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    environment_variable {
      name  = "MAVEN_CLI_OPTS"
        value = "-DskipTests"
    }
    
    
    
    # environment_variables = [
    #   {
    #     name  = "MAVEN_CLI_OPTS"
    #     value = "-DskipTests"
    #   }
    # ]
  }

  source {
    type      = "GITHUB"
    location  = "https://github.com/PrakashRajugithub/sparkjava-war-example.git"
    buildspec = <<BUILD_SPEC
version: 0.2

phases:
  install:
    commands:
      - echo Installing Maven
      - mvn install
  build:
    commands:
      - echo Building the application
      - mvn clean package
artifacts:
  files:
    - target/*.war
BUILD_SPEC
  }
}

############################################################################################################


resource "aws_codedeploy_app" "java_app" {
  name = "JavaApp"
  compute_platform = "Server"
}

resource "aws_codedeploy_deployment_group" "JavaApp" {
  app_name = aws_codedeploy_app.java_app.name
  deployment_group_name = "JavaApp"

  service_role_arn = aws_iam_role.codedeploy_role.arn

  deployment_config_name = "CodeDeployDefault.OneAtATime"
  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }
  ec2_tag_set {
    ec2_tag_filter {
      key   = "ENV"
      value = "PROD"
      type  = "KEY_AND_VALUE"
    }
  }
  load_balancer_info {
    elb_info {
      name = aws_lb.my_alb.name  # If you're using an ELB
    }
  }
}
