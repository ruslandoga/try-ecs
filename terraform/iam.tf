# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/instance_IAM_role.html

data "aws_iam_policy_document" "ecs_instance" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# needed for service discovery
data "aws_iam_policy_document" "ec2_describe" {
  statement {
    actions   = ["ec2:Describe*"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ec2_describe" {
  name   = "ec2_describe"
  policy = data.aws_iam_policy_document.ec2_describe.json
}

resource "aws_iam_role" "ecs_instance" {
  name               = "ecs_instance_role"
  assume_role_policy = data.aws_iam_policy_document.ecs_instance.json
}

resource "aws_iam_role_policy_attachment" "ecs_ec2_role" {
  role       = aws_iam_role.ecs_instance.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ecs_ec2_cloudwatch_role" {
  role       = aws_iam_role.ecs_instance.id
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_role_policy_attachment" "ec2_describe" {
  role       = aws_iam_role.ecs_instance.id
  policy_arn = aws_iam_policy.ec2_describe.id
}

resource "aws_iam_instance_profile" "ecs_instance" {
  name = "ecs_instance"
  role = aws_iam_role.ecs_instance.name
}
