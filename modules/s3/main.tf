resource "aws_s3_bucket" "processed-assets" {
  bucket        = "ebad-arshad-processed-assets-${terraform.workspace}"
  force_destroy = true

  tags = {
    Name = "ebad-arshad-processed-assets-${terraform.workspace}"
  }
}

resource "aws_s3_bucket_public_access_block" "processed_assets_public_access_block" {
  bucket = aws_s3_bucket.processed-assets.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "processed_assets_versioning" {
  bucket = aws_s3_bucket.processed-assets.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "source-uploads" {
  bucket        = "ebad-arshad-source-uploads"
  force_destroy = true

  tags = {
    Name = "ebad-arshad-source-uploads-${terraform.workspace}"
  }
}

resource "aws_s3_bucket_public_access_block" "source_uploads_public_access_block" {
  bucket = aws_s3_bucket.source-uploads.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "source_uploads_versioning" {
  bucket = aws_s3_bucket.source-uploads.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_object" "source_uploads_object" {
  for_each = fileset("${path.module}/../../images", "**")
  bucket   = aws_s3_bucket.source-uploads.id
  key      = each.value
  source   = "${path.module}/../../images/${each.value}"

  etag = filemd5("${path.module}/../../images/${each.value}")

  tags = {
    Name = "Source-Uploads-${terraform.workspace}"
  }
}



# ================================= Lambda Notification =====================================

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "lambda_s3_permissions" {
    statement {
    effect = "Allow"

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.processed-assets.arn}/*",
    ]
  }
    statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${aws_s3_bucket.source-uploads.arn}/*",
    ]
  }
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
resource "aws_iam_role_policy_attachment" "attach_s3" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_s3_policy.arn

}

resource "aws_iam_policy" "lambda_s3_policy" {
  name   = "ebad_lambda_s3_policy"
  policy = data.aws_iam_policy_document.lambda_s3_permissions.json
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.func.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.source-uploads.arn
}

data "archive_file" "example" {
  type        = "zip"
  source_file = "${path.module}/lambda/index.py"
  output_path = "${path.module}/lambda/function.zip"
}

resource "aws_lambda_function" "func" {
  filename      = data.archive_file.example.output_path
  function_name = "example_lambda_name"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "index.lambda_handler"
  runtime       = "python3.14"
  architectures = ["x86_64"]
  code_sha256   = data.archive_file.example.output_base64sha256
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.source-uploads.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.func.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".png"
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}
