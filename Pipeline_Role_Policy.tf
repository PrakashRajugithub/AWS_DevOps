# IAM Policy for CodePipeline#######################################

resource "aws_iam_policy" "codepipeline_full_access_policy" {
  name        = "CodePipelineFullAccess"
  description = "Custom policy providing full access to AWS CodePipeline"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "codepipeline:*",
          "codedeploy:*",
          "iam:PassRole",
          "cloudwatch:*",
          "s3:*",
          "sns:*",
          "kms:*"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_custom_policy_to_role" {
  role       = "CodePipelineServiceRole"  # Replace with the existing IAM role name
  policy_arn = aws_iam_policy.codepipeline_full_access_policy.arn
}
###======IAM Policy to Access Pipeline to start Build======================================================

resource "aws_iam_role_policy" "codepipeline_startbuild_policy" {
  name = "CodePipelineStartBuildPolicy"
  role = aws_iam_role.codepipeline_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   =  [
          "codebuild:StartBuild",
          "codebuild:BatchGetBuilds"
        ]
        Resource = "arn:aws:codebuild:ap-southeast-1:235494813694:project/BuildJavaApp"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_custom_policy_to_pipeline_role" {
  role       = "CodePipelineServiceRole"  # Replace with the existing IAM role name
  policy_arn = aws_iam_policy.codepipeline_full_access_policy.arn
}
###=========================================================


# IAM Role for CodePipeline############################################

resource "aws_iam_role" "codepipeline_role" {
  name = "CodePipelineServiceRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "codepipeline.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy_attachment" "codepipeline_role_attachment" {
  name = "CodePipelineFullAccess"
  policy_arn = aws_iam_policy.codepipeline_full_access_policy.arn
  roles      = [aws_iam_role.codepipeline_role.name]
}



############################################################################################################
############################################################################################################

# IAM policy for CodeBuild

resource "aws_iam_policy" "codebuild_policy" {
  name        = "CodeBuildPolicy"
  description = "Custom policy granting necessary permissions for CodeBuild"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild",
          "codebuild:StopBuild",
          "codebuild:BatchGetProjects",
          "codebuild:BatchGetBuildBatches",
          "codebuild:BatchGetReportGroups",
          "codebuild:BatchGetReports",
          "codebuild:ListBuildsForProject",
          "codebuild:ListCuratedEnvironmentImages",
          "codebuild:RetryBuild"
        ],
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = [
          "elasticloadbalancing:DescribeLoadBalancerAttributes",
          "elasticloadbalancing:DescribeTargetGroupAttributes",
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeInstanceHealth",
          "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
          "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeTargetHealth",
          "elasticloadbalancing:RegisterTargets",
          "elasticloadbalancing:DeregisterTargets"
        ],
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::storingartifacts",
          "arn:aws:s3:::storingartifacts/*"
        ]
      },
      {
        Effect   = "Allow",
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect   = "Allow",
        Action   = "iam:PassRole",
        Resource = "arn:aws:iam::235494813694:role/CodeBuildServiceRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codebuild_policy_attachment" {
  role       = "CodeBuildServiceRole"   # Replace with your existing CodeBuild role
  policy_arn = aws_iam_policy.codebuild_policy.arn
}


# IAM Role for CodeBuild

resource "aws_iam_role" "codebuild_role" {
  name = "CodeBuildServiceRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "codebuild.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy_attachment" "codebuild_role_attachment" {
  name = "CodeBuildPolicy"
  policy_arn = aws_iam_policy.codebuild_policy.arn
  roles      = [aws_iam_role.codebuild_role.name]
}
###################################################################################################
###################################################################################################

# IAM Policy for Code Deploy

resource "aws_iam_policy" "codedeploy_policy" {
  name        = "CodeDeployPolicy"
  description = "Custom policy granting necessary permissions for CodeDeploy"
  
  policy = jsonencode({
    Version: "2012-10-17",
    Statement: [
      {
        Effect: "Allow",
        Action: [
          "codedeploy:RegisterApplicationRevision",
          "codedeploy:GetDeployment",
          "codedeploy:CreateDeployment",
          "codedeploy:StopDeployment",
          "codedeploy:GetDeploymentConfig",
          "codedeploy:GetApplication",
          "codedeploy:ListDeploymentInstances"
        ],
        Resource: "*"
      },
      {
        Effect: "Allow",
        Action: [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource: [
          "arn:aws:s3:::storingartifacts",
          "arn:aws:s3:::storingartifacts/*"
        ]
      },
      {
        Effect: "Allow",
        Action: [
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceStatus"
        ],
        Resource: "*"
      },
      {
        Effect: "Allow",
        Action: [
          "autoscaling:CompleteLifecycleAction",
          "autoscaling:PutLifecycleHook",
          "autoscaling:DeleteLifecycleHook",
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeLifecycleHooks"
        ],
        Resource: "*"
      },
      {
        Effect: "Allow",
        Action: [
          "cloudwatch:PutMetricData",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource: "arn:aws:logs:*:*:*"
      },
      {
        Effect: "Allow",
        Action: "iam:PassRole",
        Resource: "arn:aws:iam::235494813694:role/CodeDeployServiceRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codedeploy_policy_attachment" {
  role       = "CodeDeployServiceRole"  # Replace with the existing IAM role for CodeDeploy
  policy_arn = aws_iam_policy.codedeploy_policy.arn
}

# IAM Role for Code Deploy

resource "aws_iam_role" "codedeploy_role" {
  name = "CodeDeployServiceRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "codedeploy.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy_attachment" "codedeploy_role_attachment" {
  name = "CodeDeployPolicy"
  policy_arn = aws_iam_policy.codedeploy_policy.arn
  roles      = [aws_iam_role.codedeploy_role.name]
}
