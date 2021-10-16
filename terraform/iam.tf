resource "aws_iam_role" "ecs_role" {
  name = "ecs_role"

  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "",
        "Effect": "Allow",
        "Principal": {
          "Service": "ecs-tasks.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }
  EOF
}

resource "aws_iam_role" "ecs_execution_role" {
  name = "ecs_execution_role"

  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "",
        "Effect": "Allow",
        "Principal": {
          "Service": "ecs-tasks.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }
  EOF
}

resource "aws_iam_policy" "ecs_policy" {
  name = "ecs_policy"

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        }
    ]
  }
  EOF
}

resource "aws_iam_policy_attachment" "attach_ecs_policy" {
  name       = "attach-ecs-policy"
  roles      = [aws_iam_role.ecs_execution_role.name]
  policy_arn = aws_iam_policy.ecs_policy.arn
}
