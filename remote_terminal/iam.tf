resource "aws_iam_instance_profile" "this" {
  name = "remote-terminal-${var.name}"
  role = aws_iam_role.this.name
}

resource "aws_iam_role" "this" {
  name = "remote-terminal-${var.name}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "this" {
  name = "ForTerraformAccess"
  role = aws_iam_role.this.name

  policy = jsonencode(var.iam_policy)
}
