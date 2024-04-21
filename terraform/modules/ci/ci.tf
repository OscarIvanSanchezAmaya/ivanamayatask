resource "aws_ecr_repository" "repo" {
  name                 = "bar"
}

resource "aws_codebuild_project" "build" {
    name = "appbuild"
    service_role = var.role
    artifacts {
        type = "CODEPIPELINE"
    }
    environment {
        compute_type                = "BUILD_GENERAL1_SMALL"
        image                       = "aws/codebuild/docker:17.09.0"
        type                        = "LINUX_CONTAINER"

        environment_variable {
        name  = "REPOSITORY_URI"
        value = "${aws_ecr_repository.repo.repository_uri}"
        }
    }
    
    source {
        type = "CODEPIPELINE"
        buildspec = templatefile(
            "${path.module}/buildspec.yml",
        )
    }
}


resource "aws_codepipeline" "codepipeline" {
    name = "pipeline"
    role_arn = var.role
    artifact_store {
      location = var.bucket
      type     = "S3"
   }

  
  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "s3"
      version          = "1"
      output_artifacts = ["app"]

      configuration = {
        S3Bucket = var.bucket
        S3ObjectKey = app.zip   # asdfasdfa
      }
    }
  }

    stage {
    name = "build"

    action {
      name             = "build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["app"]
      output_artifacts = ["BuildOutput"]

      configuration = {
        ProjectName = aws_codebuild_project.build.id
      }
    }
  }

    stage {
    name = "deploy-audio"

    action {
      name             = "deploy"
      category         = "Deploy"
      owner            = "AWS"
      provider         = "ECS"
      version          = "1"
      input_artifacts  = ["BuildOutput"]

      configuration = {
        ClusterName = var.cluster
        ServiceName = var.ServiceNameAudio
        FileName = images.json

      }
    }
  }
      stage {
    name = "deploy-video"

    action {
      name             = "deploy"
      category         = "Deploy"
      owner            = "AWS"
      provider         = "ECS"
      version          = "1"
      input_artifacts  = ["BuildOutput"]

      configuration = {
        ClusterName = var.cluster
        ServiceName = var.ServiceNameVideo
        FileName = images.json

      }
    }
  }

      stage {
    name = "deploy-images"

    action {
      name             = "deploy"
      category         = "Deploy"
      owner            = "AWS"
      provider         = "ECS"
      version          = "1"
      input_artifacts  = ["BuildOutput"]

      configuration = {
        ClusterName = var.cluster
        ServiceName = var.ServiceNameImages
        FileName = images.json

      }
    }
  }

}