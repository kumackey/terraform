resource "aws_ecr_repository" "example" {
  name = "example"
}

resource "aws_ecr_lifecycle_policy" "example" {
  repository = aws_ecr_repository.example.name
  policy = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Keep last 30 release tagged images"
      "selection": {
        "tagStatus": "tagged",
        "tagPrefixList": ["release"],
        "countType": "imageCountMoreThan",
        "countNumber": 30
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "codebuild" {
  statement {
    effect = "Allow"
    resources = [
      "*"]

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability"
    ]
  }
}

module "codebuild_role" {
  source = "./iam"
  name = "codebuild"
  identifier = "codebuild.amazonaws.com"
  policy = data.aws_iam_policy_document.codebuild.json
}

resource "aws_codebuild_project" "example" {
  name = "example"
  service_role = module.codebuild_role.iam_role_arn
  artifacts {
    type = "CODEPIPELINE"
  }
  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image = "aws/codebuild/standard:2.0"
    type = "LINUX_CONTAINER"
    privileged_mode = true
  }
  source {
    type = "CODEPIPELINE"
  }
}

data "aws_iam_policy_document" "codepipeline" {
  statement {
    effect = "Allow"
    resources = [
      "*"]

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability"
    ]
  }
}

module "codepipeline_role" {
  source = "./iam"
  name = "codepipeline"
  identifier = "codepipeline.amazonaws.com"
  policy = data.aws_iam_policy_document.codepipeline.json
}

resource "aws_s3_bucket" "artifact" {
  bucket = "artifact-pragmatic-terraform"

  lifecycle_rule {
    enabled = true

    expiration {
      days = "180"
    }
  }
}

resource "aws_codepipeline" "example" {
  name = "example"
  role_arn = module.codepipeline_role.iam_role_arn

  artifact_store {
    location = aws_s3_bucket.artifact.id
    type = "S3"
  }

  stage {
    name = "Source"

    action {
      category = "Source"
      name = "Source"
      owner = "ThirdParty"
      provider = "GitHub"
      version = 1
      output_artifacts = [
        "Source"]

      configuration = {
        Owner = "kumackey"
        Repo = "terraform-kumaki"
        Branch = "master"
        PollForSourceChange = false
      }
    }
  }

  stage {
    name = "Build"

    action {
      category = "Build"
      name = "Build"
      owner = "AWS"
      provider = "CodeBuild"
      version = 1
      input_artifacts = [
        "Source"]
      output_artifacts = [
        "Build"]

      configuration = {
        projectName = aws_codebuild_project.example.id
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      category = "Deploy"
      name = "Deploy"
      owner = "AWS"
      provider = "ECS"
      version = 1
      input_artifacts = [
        "Build"]

      configuration = {
        ClusterName = aws_ecs_cluster.example.name
        ServiceName = aws_ecs_service.example.name
        FileName = "imagedefinations.json"
      }
    }
  }
}

resource "aws_codepipeline_webhook" "example" {
  authentication = "GITHUB_HMAC"
  name = "example"
  target_action = "Source"
  target_pipeline = aws_codepipeline.example.name

  authentication_configuration {
    secret_token = "VeryRandomString"
  }

  filter {
    json_path = "$.ref"
    match_equals = "refs/heads/{Branch}"
  }
}

provider "github" {
  organization = "kumackey"
}

resource "github_repository_webhook" "example" {
  events = [
    "push"]
  repository = "kumackey"
  configuration {
    url = aws_codepipeline_webhook.example.url
    secret = "VeryRandomString"
    content_type = "json"
    insecure_ssl = false
  }
}