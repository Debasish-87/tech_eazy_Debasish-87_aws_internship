resource "aws_iam_role" "s3_read_role" {
  name = "${var.environment}_s3_read_role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

resource "aws_iam_role" "s3_write_role" {
  name = "${var.environment}_s3_write_role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

resource "aws_iam_policy" "s3_read_policy" {
  name   = "${var.environment}_s3_read_policy"
  policy = data.aws_iam_policy_document.s3_read_policy.json
}

resource "aws_iam_policy" "s3_write_policy" {
  name   = "${var.environment}_s3_write_policy"
  policy = data.aws_iam_policy_document.s3_write_policy.json
}

resource "aws_iam_role_policy_attachment" "attach_read" {
  role       = aws_iam_role.s3_read_role.name
  policy_arn = aws_iam_policy.s3_read_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_write" {
  role       = aws_iam_role.s3_write_role.name
  policy_arn = aws_iam_policy.s3_write_policy.arn
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.environment}_ec2_profile"
  role = aws_iam_role.s3_write_role.name
}


