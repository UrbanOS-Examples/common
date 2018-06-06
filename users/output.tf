output "1-username" {
  value = "${aws_iam_user.user.*.name}"
}

output "2-password" {
  // export with `terraform output password | base64 -d | gpg`
  value = "${aws_iam_user_login_profile.user-login-profile.*.encrypted_password}"
}
