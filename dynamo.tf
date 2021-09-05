resource "aws_dynamodb_table" "dynamodb-tf-state-lock" {
        name            = "terraform-lock"
        hash_key        = "LockID"
        read_capacity   = 5
        write_capacity  = 5

  attribute {
        name            = "LockID"
        type            = "S"
  }
depends_on              = [aws_s3_bucket.remote_s3_bucket]
}