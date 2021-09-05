resource "aws_s3-bucket" "remote_s3_bucket" {
        bucket          =       "tf.state-bucket"
        acl             =       "private"
    versioning {
        enabled         =       true
     }
    tags = {
        Name            =       "tf.state-buket"
    }
}