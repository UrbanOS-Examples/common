vpc_name = "sandbox-alm"

environment = "sandbox-alm"

root_dns_name = "smartcolumbusos.com"

openvpn_admin_password_secret_arn = "arn:aws:secretsmanager:us-east-2:068920858268:secret:openvpn_admin_password-8p4kVH"

docker_registry = "068920858268.dkr.ecr.us-east-2.amazonaws.com"

cluster_instance_ssh_public_key_path = "files/oasis_id_rsa.pub"

cluster6_instance_ssh_public_key_path = "files/oasis6_id_rsa.pub"

cluster_instance_type = "t2.medium"

cluster_minimum_size = 1

cluster_maximum_size = 3

cluster_desired_capacity = 2

domain_name = "deliveryPipeline.smartcolumbusos.com"

alm_account_id = "068920858268"

alm_role_arn = "arn:aws:iam::068920858268:role/admin_role"

alm_state_bucket_name = "scos-sandbox-terraform-state"

key_pair_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDRAvH6k7iEeRDz9SQtkH1o8KiUaed/e2hmzTUjA8bhmeWVLPsgCMKIUKR0jdPlvdZ0AmMLXswobsXj08dPgWxUZxoAWIqKCjd969KckydUpBtcb+X2Q+tpOcugBOQSY1H8hgNrdcRKEaUllTfvseJ9pBOYU7j9VuZ608HQhfZw7+aS8wi9o/BJwejtpWdlo6gkxXoIRqDX/ioYg+W6Tc7yoUzAEANwZAy3/3GKWDrh+9jnzR6mEEN48Nuee49wWfP5G0T/v4+Gvux5zioHb3rcmmR9YTkFOiv1poInhXlPdc7Q38yj+z6E+hACNN3rK80YjU0ByaSPltPjqm9ZYmPX"
