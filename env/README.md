# How to get database passwords

The database passwords are randomly generated and stored in the terraform state

Get a list of passwords stored in the terraform state:
```
terraform state list | grep db_password
```

Show the password, using joomla as an example:
```
# terraform state show dumps a lot of lines, the only one that matters for passwords is `result`
terraform state show random_string.joomla_db_password | grep result
```