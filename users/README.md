This directory contains the Terraform definition for the *sandbox* environment users.

The Terraform AWS module uses PGP keys to encrypt user passwords on creation.
To apply this module you need to supply your base64 encoded PGP key or keybase username.

The script takes care of this for you, but you need to have [gpg](www.gnupg.org) installed and a key pair available.

On Mac

```bash
# install
brew install gpg2
echo 'export GPG_TTY=$(tty)' >> ~/.bash_profile
. ~/.bash_profile

# generate your keypair
gpg --generate-key
```

Update the list of users in [variables.tf](variables.tf).
Then run the shell script to create the users and output their one time use passwords.

```bash
./run.sh > someFileName
```

Finally, you'll need to securely deliver each user their one time user password.