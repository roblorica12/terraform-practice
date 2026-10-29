variable "bucket_name" {
  type = string
}

resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
}

resource "aws_iam_policy" "read_policy" {
  name        = "${var.bucket_name}-read-policy"
  description = "Allows read access to ${var.bucket_name}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject"]
        Resource = "${aws_s3_bucket.this.arn}/*"
      }
    ]
  })
}

output "bucket_arn" {
  value = aws_s3_bucket.this.arn
}

output "policy_arn" {
  value = aws_iam_policy.read_policy.arn
}

