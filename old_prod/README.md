Do before a terraform apply or the Joomla! provision will fail.  Note that the old sandbox vpn ssh key, and joomla prod ssh key must be in a known location on the filesystem in order to apply this terraform.

```
ssh-agent
export SSH_AGENT_PID=<pid from ssh-agent command>

ssh-add <path to sandbox-vpn key>
ssh-add <path to prod-joomla>
```

please have desired database password and prodS3ReadOnly AWS credentials readily availible
