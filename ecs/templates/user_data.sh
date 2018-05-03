#!/bin/bash

echo ECS_CLUSTER=${cluster_name} >> /etc/ecs/ecs.config

sudo apt-get update
sudo apt-get install --yes nfs-common
sudo mkdir -p ${mount_point}
sudo chown -R ubuntu ${mount_point}
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 ${efs_file_system_dns_name}:/ ${mount_point}
