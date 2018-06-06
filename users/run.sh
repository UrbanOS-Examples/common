#!/bin/bash

terraform apply -var pgp_key="$(gpg --export | base64)"
usernames=($(terraform output 1-username | tr "," "\n"))
passwords=($(terraform output 2-password | tr "," "\n"))

for index in ${!usernames[*]}; do 
  username=${usernames[$index]}
  password=${passwords[$index]}
 
  password=$(echo $password | base64 --decode | gpg --decrypt)
  echo "$username: $password"
done
