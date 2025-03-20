provider "aws" {
  region = "us-east-1"  
}

variable "name" {
  description = "The IAM username"
  type        = string
}

variable "email" {
  description = "The IAM user's email address"
  type        = string
}

# Create the IAM user
resource "aws_iam_user" "s3_user" {
  name = var.name
}

# Create an IAM policy that allows full access to S3
resource "aws_iam_policy" "s3_policy" {
  name        = "${var.name}-s3-policy"
  description = "IAM policy for S3 access only"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "s3:*"
        Resource = "arn:aws:s3:::*"
      }
    ]
  })
}

# Attach the policy to the user
resource "aws_iam_policy_attachment" "s3_policy_attachment" {
  name       = "${var.name}-s3-policy-attachment"
  users      = [aws_iam_user.s3_user.name]
  policy_arn = aws_iam_policy.s3_policy.arn
}

# Create an IAM access key for the user
resource "aws_iam_access_key" "access_key" {
  user = aws_iam_user.s3_user.name
}

# Send the IAM user details (name, email, access key) to the user
resource "aws_ses_email_identity" "email_identity" {
  email = var.email
}

resource "aws_ses_send_email" "send_user_details" {
  to_addresses = [var.email]
  subject      = "Your AWS IAM User Details"
  body         = "Dear ${var.name},\n\nHere are your IAM user details:\n\nUsername: ${var.name}\nAccess Key: ${aws_iam_access_key.access_key.id}\n\nPlease keep these credentials safe.\n\nBest Regards, AWS Admin"
}
