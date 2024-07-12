resource "aws_codepipeline" "codepipeline" {
  name     = "static-website-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    type     = "S3"
    location = "www.colby-smith-labs.com"
  }

  stage {
    name = "Source"

    action {
      name             = "CodeConnection_Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = "arn:aws:codeconnections:eu-west-1:905418352433:connection/3141d639-12bf-422e-a02d-7d20dafc0b4a"
        FullRepositoryId = "Colby-Smith/Personal-Site"
        BranchName       = "main"
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
      name             = "S3_Deploy"
      category         = "Deploy"
      owner            = "AWS"
      provider         = "S3"
      version          = "1"
      input_artifacts  = ["build_output"]

      configuration = {
        BucketName = "www.colby-smith-labs.com"
        Extract    = "true"
      }
    }
  }
}