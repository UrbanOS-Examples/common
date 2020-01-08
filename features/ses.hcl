resource "aws_ses_domain_identity" "domain" {
  domain = "${aws_route53_zone.root_public_hosted_zone.name}"
}

resource "aws_ses_domain_dkim" "dkim" {
  domain = "${aws_ses_domain_identity.domain.domain}"
}

resource "aws_route53_record" "domain_amazonses_verification_record" {
  count   = 1
  zone_id = "${aws_route53_zone.root_public_hosted_zone.zone_id}"
  name    = "_amazonses.${aws_route53_zone.root_public_hosted_zone.name}"
  type    = "TXT"
  ttl     = "3600"
  records = ["${aws_ses_domain_identity.domain.verification_token}"]
}

resource "aws_route53_record" "domain_amazonses_dkim_record" {
  count   = 3
  zone_id = "${aws_route53_zone.root_public_hosted_zone.zone_id}"
  name    = "${element(aws_ses_domain_dkim.dkim.dkim_tokens, count.index)}._domainkey.${aws_route53_zone.root_public_hosted_zone.name}"
  type    = "CNAME"
  ttl     = "3600"
  records = ["${element(aws_ses_domain_dkim.dkim.dkim_tokens, count.index)}.dkim.amazonses.com"]
}

resource "aws_iam_access_key" "smtp_user" {
  user    = "${aws_iam_user.smtp_user.name}"
}

resource "aws_iam_user" "smtp_user" {
  name = "smtp_user"
}

resource "aws_iam_user_policy" "smtp_user" {
  name = "test"
  user = "${aws_iam_user.smtp_user.name}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "ses:SendRawEmail",
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_ses_email_identity" "smartcolumbusos_email" {
  email = "smartcolumbusos@columbus.gov"
}