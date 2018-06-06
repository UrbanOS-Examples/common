provider "aws" {
  region = "${var.region}"
}

resource "aws_iam_user" "user" {
  count         = "${length(var.users)}"
  name          = "${var.users[count.index]}"
  force_destroy = true
}

resource "aws_iam_user_login_profile" "user-login-profile" {
  count                   = "${length(var.users)}"
  user                    = "${var.users[count.index]}"
  pgp_key                 = "${var.pgp_key}"
  password_reset_required = true
  depends_on              = ["aws_iam_user.user"]
}

resource "aws_iam_group_membership" "dev-group-membership" {
  name       = "dev-group-membership"
  users      = "${var.users}"
  group      = "${aws_iam_group.dev-group.name}"
  depends_on = ["aws_iam_user.user"]
}

resource "aws_iam_group" "dev-group" {
  name = "developers"
}

resource "aws_iam_group_policy_attachment" "dev-group-policy-ViewOnlyAccess" {
  group      = "${aws_iam_group.dev-group.name}"
  policy_arn = "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"
}

resource "aws_iam_group_policy_attachment" "dev-group-policy-IAMUserChangePassword" {
  group      = "${aws_iam_group.dev-group.name}"
  policy_arn = "arn:aws:iam::aws:policy/IAMUserChangePassword"
}

resource "aws_iam_policy" "policy-dev-assumed-role" {
  name	     = "dev_assumed_roles_policy"
  description= "This policy allows devs to assume roles in other environments"

  policy     = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "123",
            "Effect": "Allow",
            "Action": [
                "sts:AssumeRole"
            ],
            "Resource": [
                "arn:aws:iam::068920858268:role/admin_role",
		"arn:aws:iam::073132350570:role/dev_view_only_role",
		"arn:aws:iam::647770347641:role/dev_view_only_role",
		"arn:aws:iam::784801362222:role/dev_view_only_role"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_group_policy_attachment" "dev-assumed-roles" {
  group      = "${aws_iam_group.dev-group.name}"
  policy_arn = "${aws_iam_policy.policy-dev-assumed-role.arn}"
}
