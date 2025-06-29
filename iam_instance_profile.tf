resource "aws_iam_instance_profile" "ec2_instance_profile_b" {
  count = var.stage =="dev" ? 1:0
  name = "ec2-instance-profile_b"
  role = aws_iam_role.role_b_uploader[0].name
}

resource "aws_iam_instance_profile" "ec2_instance_profile_a" {
  count = var.stage =="dev" ? 1:0
  name = "ec2-instance-profile_a-${var.stage}"
  role = aws_iam_role.role_a_readonly[0].name
}

# Reuse in prod data block
data "aws_iam_instance_profile" "ec2_instance_profile_b" {
  count = var.stage =="prod" ? 1:0
  name = "ec2-instance-profile_b"
}